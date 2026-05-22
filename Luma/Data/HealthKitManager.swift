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

    struct HeartRateTrendReading {
        let bpm: Double
        let startDate: Date
        let endDate: Date
    }

    struct HRVReading {
        let sdnnMs: Double
        let startDate: Date
        let endDate: Date
    }

    struct SleepTrendReading {
        let label: String
        let hours: Double
        let startDate: Date
        let endDate: Date
    }

    struct HealthSnapshot {
        let heartRate: HeartRateReading?
        let hrvSDNNMs: Double?
        let sleepHours: Double?
        let heartRateTrend: [HeartRateTrendReading]
        let hrvTrend: [HRVReading]
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
        
        let trendStartDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date().addingTimeInterval(-7 * 24 * 60 * 60)
        var heartRateTrend: [HeartRateTrendReading] = []
        var hrvTrend: [HRVReading] = []

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
        
        group.enter()
        fetchHeartRateReadings(from: trendStartDate) { readings in
            heartRateTrend = readings
            group.leave()
        }

        group.enter()
        fetchHRVReadings(from: trendStartDate) { readings in
            hrvTrend = readings
            group.leave()
        }

        group.notify(queue: .global()) {
            let hasAny = latestHeartRate != nil || latestHRV != nil || latestSleepHours != nil || !heartRateTrend.isEmpty || !hrvTrend.isEmpty
            guard hasAny else {
                completion(nil)
                return
            }

            completion(
                HealthSnapshot(
                    heartRate: latestHeartRate,
                    hrvSDNNMs: latestHRV,
                    sleepHours: latestSleepHours,
                    heartRateTrend: heartRateTrend,
                    hrvTrend: hrvTrend,
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


    // Heart rate trend: fetch Apple Watch / Health app heart-rate samples for a custom date range, in bpm.
    func fetchHeartRateReadings(
        from startDate: Date,
        to endDate: Date = Date(),
        completion: @escaping ([HeartRateTrendReading]) -> Void
    ) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion([])
            return
        }

        if !hasCompletedInitialAuthorizationFlow {
            requestAuthorization { [weak self] success in
                guard success, let self else {
                    completion([])
                    return
                }
                self.fetchHeartRateReadings(from: startDate, to: endDate, completion: completion)
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
            sampleType: heartRateType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error {
                print("❌ Failed to read heart-rate trend samples: \(error.localizedDescription)")
                completion([])
                return
            }

            let quantitySamples = samples as? [HKQuantitySample] ?? []
            guard !quantitySamples.isEmpty else {
                print("ℹ️ No heart-rate trend sample available in selected range.")
                completion([])
                return
            }

            let watchSamples = quantitySamples.filter(\.isAppleWatchSource)

            // Prefer Apple Watch samples. If source metadata is unavailable, fall back to all heart-rate samples
            // so the chart can still display data already synced into Apple Health.
            let displaySamples = watchSamples.isEmpty ? quantitySamples : watchSamples

            let unit = HKUnit.count().unitDivided(by: .minute())
            let readings = displaySamples.map { sample in
                HeartRateTrendReading(
                    bpm: sample.quantity.doubleValue(for: unit),
                    startDate: sample.startDate,
                    endDate: sample.endDate
                )
            }

            print("❤️ Heart-rate trend samples loaded: \(readings.count) from \(startDate) to \(endDate)")
            completion(readings)
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
            let displaySamples = watchSamples.isEmpty ? quantitySamples : watchSamples

            let values = displaySamples.map {
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

    // Sleep: calculate asleep duration from the current overnight sleep window.
    func fetchSleepHoursFromLastNight(completion: @escaping (Double?) -> Void) {
        let window = currentOvernightSleepWindow()
        fetchSleepHours(from: window.start, to: window.end, label: "Today") { reading in
            completion(reading?.hours)
        }
    }

    func fetchSleepTrendReadings(
        range: SleepTrendRange,
        completion: @escaping ([SleepTrendReading]) -> Void
    ) {
        switch range {
        case .day:
            let window = currentOvernightSleepWindow()
            fetchSleepHours(from: window.start, to: window.end, label: "Today") { reading in
                completion(reading.map { [$0] } ?? [])
            }
        case .week:
            fetchSleepTrendForRecentDays(dayCount: 7, completion: completion)
        case .month:
            fetchSleepTrendForRecentWeeks(weekCount: 4, completion: completion)
        }
    }

    private func fetchSleepTrendForRecentDays(
        dayCount: Int,
        completion: @escaping ([SleepTrendReading]) -> Void
    ) {
        let calendar = Calendar.current
        let today = Date()
        let group = DispatchGroup()
        var readings: [SleepTrendReading] = []
        let lock = NSLock()

        for offset in stride(from: dayCount - 1, through: 0, by: -1) {
            guard let targetDay = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let window = overnightSleepWindow(endingOn: targetDay)
            let label = weekdayLabel(for: targetDay)

            group.enter()
            fetchSleepHours(from: window.start, to: window.end, label: label) { reading in
                if let reading {
                    lock.lock()
                    readings.append(reading)
                    lock.unlock()
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(readings.sorted { $0.startDate < $1.startDate })
        }
    }

    private func fetchSleepTrendForRecentWeeks(
        weekCount: Int,
        completion: @escaping ([SleepTrendReading]) -> Void
    ) {
        let calendar = Calendar.current
        let today = Date()
        let group = DispatchGroup()
        var readings: [SleepTrendReading] = []
        let lock = NSLock()

        for offset in stride(from: weekCount - 1, through: 0, by: -1) {
            guard
                let weekEndDay = calendar.date(byAdding: .day, value: -(offset * 7), to: today),
                let weekStartDay = calendar.date(byAdding: .day, value: -6, to: weekEndDay)
            else { continue }

            let label = offset == 0 ? "This W" : "W-\(offset)"
            let dayGroup = DispatchGroup()
            var dailyHours: [Double] = []

            for dayOffset in 0..<7 {
                guard let targetDay = calendar.date(byAdding: .day, value: dayOffset, to: weekStartDay) else { continue }
                let window = overnightSleepWindow(endingOn: targetDay)

                dayGroup.enter()
                fetchSleepHours(from: window.start, to: window.end, label: weekdayLabel(for: targetDay)) { reading in
                    if let reading {
                        lock.lock()
                        dailyHours.append(reading.hours)
                        lock.unlock()
                    }
                    dayGroup.leave()
                }
            }

            group.enter()
            dayGroup.notify(queue: .global()) {
                guard !dailyHours.isEmpty else {
                    group.leave()
                    return
                }

                let averageHours = dailyHours.reduce(0, +) / Double(dailyHours.count)
                let weekWindow = self.weekDisplayWindow(startDay: weekStartDay, endDay: weekEndDay)
                let reading = SleepTrendReading(
                    label: label,
                    hours: averageHours,
                    startDate: weekWindow.start,
                    endDate: weekWindow.end
                )

                lock.lock()
                readings.append(reading)
                lock.unlock()
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(readings.sorted { $0.startDate < $1.startDate })
        }
    }

    private func fetchSleepHours(
        from startDate: Date,
        to endDate: Date,
        label: String,
        completion: @escaping (SleepTrendReading?) -> Void
    ) {
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
                self.fetchSleepHours(from: startDate, to: endDate, label: label, completion: completion)
            }
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

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

            let categorySamples = samples as? [HKCategorySample] ?? []
            guard !categorySamples.isEmpty else {
                print("ℹ️ No sleep sample available for \(label).")
                completion(nil)
                return
            }

            let watchSamples = categorySamples.filter(\.isAppleWatchSource)
            let displaySamples = watchSamples.isEmpty ? categorySamples : watchSamples

            let asleepSeconds = displaySamples
                .filter { HKCategoryValueSleepAnalysis(rawValue: $0.value).isAsleep }
                .reduce(0.0) { partial, sample in
                    let clippedStart = max(sample.startDate, startDate)
                    let clippedEnd = min(sample.endDate, endDate)
                    let duration = clippedEnd.timeIntervalSince(clippedStart)
                    return partial + max(0, duration)
                }

            let hours = asleepSeconds / 3600.0
            print("😴 Sleep duration \(label): \(String(format: "%.2f", hours)) h")

            guard hours > 0 else {
                completion(nil)
                return
            }

            completion(
                SleepTrendReading(
                    label: label,
                    hours: hours,
                    startDate: startDate,
                    endDate: endDate
                )
            )
        }

        healthStore.execute(query)
    }

    private func currentOvernightSleepWindow() -> (start: Date, end: Date) {
        overnightSleepWindow(endingOn: Date())
    }

    private func overnightSleepWindow(endingOn day: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: day)
        let start = calendar.date(byAdding: .hour, value: -6, to: startOfDay) ?? day.addingTimeInterval(-30 * 60 * 60)
        let end = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: day) ?? day

        if calendar.isDateInToday(day) {
            return (start, min(end, Date()))
        }

        return (start, end)
    }

    private func weekDisplayWindow(startDay: Date, endDay: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDay)
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDay) ?? endDay
        return (start, end)
    }

    private func weekdayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "E"
        return formatter.string(from: date)
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


enum SleepTrendRange {
    case day
    case week
    case month
}
