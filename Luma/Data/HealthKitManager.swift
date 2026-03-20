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

        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("❌ Failed to create heart rate type.")
            completion?(false)
            return
        }

        let readTypes: Set<HKObjectType> = [heartRateType]

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
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("⚠️ Unable to build heartRate type for status snapshot.")
            return
        }

        let heartStatus = healthStore.authorizationStatus(for: heartRateType)
        print("🩺 HealthKit status snapshot - heartRate: \(heartStatus.readable)")
    }

    struct HeartRateReading {
        let bpm: Double
        let endDate: Date
    }

    // Day 2 scope (heart rate only): read latest Apple Watch sampled heart rate.
    func fetchLatestHeartRate(completion: @escaping (HeartRateReading?) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("⚠️ Unable to build heartRate type.")
            completion(nil)
            return
        }

        let authStatus = healthStore.authorizationStatus(for: heartRateType)
        if authStatus == .notDetermined {
            // Fallback: if app entry flow missed permission prompt, ask here.
            requestAuthorization { [weak self] success in
                guard success, let self else {
                    completion(nil)
                    return
                }
                self.fetchLatestHeartRate(completion: completion)
            }
            return
        }

        guard authStatus == .sharingAuthorized else {
            print("⚠️ Heart rate read permission not granted yet.")
            completion(nil)
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
        guard let productType = sourceRevision.productType else {
            return false
        }
        return productType.lowercased().hasPrefix("watch")
    }
}
