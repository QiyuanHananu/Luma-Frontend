//
//  HealthKitManager.swift
//  Luma
//

import Foundation
import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()
    private let authorizationCallbackKey = "healthkit.authorization.callback.received"

    private init() {}

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    var hasCompletedInitialAuthorizationFlow: Bool {
        UserDefaults.standard.bool(forKey: authorizationCallbackKey)
    }

    func requestAuthorizationIfNeeded() {
        if hasCompletedInitialAuthorizationFlow {
            print("ℹ️ HealthKit authorization flow already completed before.")
            return
        }
        requestAuthorization()
    }

    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        guard isHealthDataAvailable else {
            print("❌ HealthKit unavailable on this device.")
            completion?(false)
            return
        }

        guard
            let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate),
            let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        else {
            print("❌ Failed to create required HealthKit types.")
            completion?(false)
            return
        }

        let readTypes: Set<HKObjectType> = [heartRateType, hrvType, sleepType]

        healthStore.requestAuthorization(toShare: [], read: readTypes) { [weak self] success, error in
            UserDefaults.standard.set(true, forKey: self?.authorizationCallbackKey ?? "healthkit.authorization.callback.received")

            if success {
                print("✅ HealthKit authorization granted.")
            } else {
                let reason = error?.localizedDescription ?? "User may have denied permissions in Health settings."
                print("❌ HealthKit authorization failed: \(reason)")
            }

            completion?(success)
        }
    }

    // Day 1 scope: permission status visibility for debugging only.
    func logAuthorizationSnapshot() {
        guard
            let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate),
            let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        else {
            print("⚠️ Unable to build HealthKit types for status snapshot.")
            return
        }

        let heartStatus = healthStore.authorizationStatus(for: heartRateType)
        let hrvStatus = healthStore.authorizationStatus(for: hrvType)
        let sleepStatus = healthStore.authorizationStatus(for: sleepType)
        print("🩺 HealthKit status snapshot - heartRate: \(heartStatus.readable), hrv: \(hrvStatus.readable), sleep: \(sleepStatus.readable)")
    }

    struct HeartRateReading {
        let bpm: Double
        let endDate: Date
    }

    struct HRVReading {
        let sdnnMs: Double
        let startDate: Date
        let endDate: Date
    }

    struct HealthSnapshot {
        let heartRate: HeartRateReading?
        let hrvSDNNMs: Double?
        let sleepHours: Double?
        let capturedAt: Date
    }

    func fetchLatestHealthSnapshot(completion: @escaping (HealthSnapshot?) -> Void) {
        guard HKObjectType.quantityType(forIdentifier: .heartRate) != nil else {
            print("⚠️ Unable to build heartRate type.")
            completion(nil)
            return
        }

        if !hasCompletedInitialAuthorizationFlow {
            requestAuthorization { [weak self] success in
                guard success, let self else {
                    completion(nil)
                    return
                }
                self.fetchLatestHealthSnapshot(completion: completion)
            }
            return
        }

        let group = DispatchGroup()
        var latestHeartRate: HeartRateReading?
        var latestHRV: Double?
        var latestSleepHours: Double?

        group.enter()
        fetchLatestHeartRate { reading in
            latestHeartRate = reading
            group.leave()
        }

        group.enter()
        fetchAverageHRVLast24Hours { value in
            latestHRV = value
            group.leave()
        }

        group.enter()
        fetchSleepHoursFromLastNight { hours in
            latestSleepHours = hours
            group.leave()
        }

        group.notify(queue: .global()) {
            let hasAny = latestHeartRate != nil || latestHRV != nil || latestSleepHours != nil
            guard hasAny else {
                completion(nil)
                return
            }

            completion(
                HealthSnapshot(
                    heartRate: latestHeartRate,
                    hrvSDNNMs: latestHRV,
                    sleepHours: latestSleepHours,
                    capturedAt: Date()
                )
            )
        }
    }

    // Heart rate: latest Apple Watch sampled heart rate.
    func fetchLatestHeartRate(completion: @escaping (HeartRateReading?) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }

        if !hasCompletedInitialAuthorizationFlow {
            requestAuthorization { [weak self] success in
                guard success, let self else {
                    completion(nil)
                    return
                }
                self.fetchLatestHeartRate(completion: completion)
            }
            return
        }

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )

        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: nil,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error {
                print("❌ Failed to read latest heart rate: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let quantitySamples = samples as? [HKQuantitySample], !quantitySamples.isEmpty else {
                print("ℹ️ No heart rate sample available.")
                completion(nil)
                return
            }

            guard let sample = quantitySamples.first(where: { $0.isAppleWatchSource }) else {
                print("ℹ️ No Apple Watch heart rate sample available.")
                completion(nil)
                return
            }

            let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            print("❤️ Latest Apple Watch heart rate: \(String(format: "%.1f", bpm)) bpm at \(sample.endDate)")
            completion(HeartRateReading(bpm: bpm, endDate: sample.endDate))
        }

        healthStore.execute(query)
    }


    // HRV (SDNN): average Apple Watch samples from the last 24 hours, in ms.
    func fetchAverageHRVLast24Hours(completion: @escaping (Double?) -> Void) {
        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            completion(nil)
            return
        }

        if !hasCompletedInitialAuthorizationFlow {
            requestAuthorization { [weak self] success in
                guard success, let self else {
                    completion(nil)
                    return
                }
                self.fetchAverageHRVLast24Hours(completion: completion)
            }
            return
        }

        let start = Date().addingTimeInterval(-24 * 60 * 60)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: hrvType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error {
                print("❌ Failed to read HRV: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let quantitySamples = samples as? [HKQuantitySample], !quantitySamples.isEmpty else {
                print("ℹ️ No HRV sample available in last 24h.")
                completion(nil)
                return
            }

            let watchSamples = quantitySamples.filter(\.isAppleWatchSource)
            guard !watchSamples.isEmpty else {
                print("ℹ️ No Apple Watch HRV sample available in last 24h.")
                completion(nil)
                return
            }

            let values = watchSamples.map {
                $0.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            }
            let avg = values.reduce(0, +) / Double(values.count)
            print("💓 HRV (SDNN) avg last 24h: \(String(format: "%.1f", avg)) ms")
            completion(avg)
        }

        healthStore.execute(query)
    }

    // HRV trend: fetch Apple Watch / Health app HRV samples for a custom date range, in ms.
    func fetchHRVReadings(
        from startDate: Date,
        to endDate: Date = Date(),
        completion: @escaping ([HRVReading]) -> Void
    ) {
        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            completion([])
            return
        }

        if !hasCompletedInitialAuthorizationFlow {
            requestAuthorization { [weak self] success in
                guard success, let self else {
                    completion([])
                    return
                }
                self.fetchHRVReadings(from: startDate, to: endDate, completion: completion)
            }
            return
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: true
        )

        let query = HKSampleQuery(
            sampleType: hrvType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error {
                print("❌ Failed to read HRV trend samples: \(error.localizedDescription)")
                completion([])
                return
            }

            let quantitySamples = samples as? [HKQuantitySample] ?? []
            guard !quantitySamples.isEmpty else {
                print("ℹ️ No HRV trend sample available in selected range.")
                completion([])
                return
            }

            let watchSamples = quantitySamples.filter(\.isAppleWatchSource)

            // Prefer Apple Watch samples. If source metadata is unavailable, fall back to all HRV samples
            // so the chart can still display data already synced into Apple Health.
            let displaySamples = watchSamples.isEmpty ? quantitySamples : watchSamples

            let readings = displaySamples.map { sample in
                HRVReading(
                    sdnnMs: sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)),
                    startDate: sample.startDate,
                    endDate: sample.endDate
                )
            }

            print("💓 HRV trend samples loaded: \(readings.count) from \(startDate) to \(endDate)")
            completion(readings)
        }

        healthStore.execute(query)
    }

    // Sleep: calculate asleep duration from last night (18:00 yesterday to 12:00 today), in hours.
    func fetchSleepHoursFromLastNight(completion: @escaping (Double?) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil)
            return
        }

        if !hasCompletedInitialAuthorizationFlow {
            requestAuthorization { [weak self] success in
                guard success, let self else {
                    completion(nil)
                    return
                }
                self.fetchSleepHoursFromLastNight(completion: completion)
            }
            return
        }

        let calendar = Calendar.current
        let now = Date()
        guard
            let todayNoon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now),
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
            let yesterday18 = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: yesterday)
        else {
            completion(nil)
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: yesterday18, end: todayNoon)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error {
                print("❌ Failed to read sleep data: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let categorySamples = samples as? [HKCategorySample], !categorySamples.isEmpty else {
                print("ℹ️ No sleep sample available for last night.")
                completion(nil)
                return
            }

            let watchSamples = categorySamples.filter(\.isAppleWatchSource)
            guard !watchSamples.isEmpty else {
                print("ℹ️ No Apple Watch sleep sample available for last night.")
                completion(nil)
                return
            }

            let asleepSeconds = watchSamples
                .filter { HKCategoryValueSleepAnalysis(rawValue: $0.value).isAsleep }
                .reduce(0.0) { partial, sample in
                    partial + sample.endDate.timeIntervalSince(sample.startDate)
                }

            let hours = asleepSeconds / 3600.0
            print("😴 Sleep duration last night: \(String(format: "%.2f", hours)) h")
            completion(hours > 0 ? hours : nil)
        }

        healthStore.execute(query)
    }
}

private extension HKAuthorizationStatus {
    var readable: String {
        switch self {
        case .notDetermined:
            return "notDetermined"
        case .sharingDenied:
            return "sharingDenied"
        case .sharingAuthorized:
            return "sharingAuthorized"
        @unknown default:
            return "unknown"
        }
    }
}

private extension HKSample {
    var isAppleWatchSource: Bool {
        let sourceName = sourceRevision.source.name.lowercased()
        let productType = sourceRevision.productType?.lowercased() ?? ""
        let deviceName = device?.name?.lowercased() ?? ""
        let deviceManufacturer = device?.manufacturer?.lowercased() ?? ""

        return productType.hasPrefix("watch") ||
            productType.contains("watch") ||
            sourceName.contains("watch") ||
            deviceName.contains("watch") ||
            deviceManufacturer.contains("apple")
    }
}

private extension HKCategoryValueSleepAnalysis? {
    var isAsleep: Bool {
        guard let value = self else { return false }
        switch value {
        case .asleepUnspecified, .asleepCore, .asleepDeep, .asleepREM:
            return true
        default:
            return false
        }
    }
}
