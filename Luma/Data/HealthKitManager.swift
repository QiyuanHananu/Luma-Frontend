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
//        if hasCompletedInitialAuthorizationFlow {
//            print("ℹ️ HealthKit authorization flow already completed before.")
//            return
//        }
        requestAuthorization()
    }

    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        guard isHealthDataAvailable else {
            print("❌ HealthKit unavailable on this device.")
            completion?(false)
            return
        }

        guard let restingHeartRateType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            print("❌ Failed to create resting heart rate type.")
            completion?(false)
            return
        }

        let readTypes: Set<HKObjectType> = [restingHeartRateType]

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
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
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
    func fetchLatestRestingHeartRate(completion: @escaping (HeartRateReading?) -> Void) {
        guard let restingHeartRateType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            print("❌ Unable to build resting heart rate type.")
            completion(nil)
            return
        }

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )

        let query = HKSampleQuery(
            sampleType: restingHeartRateType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error = error {
                print("❌ Resting heart rate query error:", error.localizedDescription)
                DispatchQueue.main.async { completion(nil) }
                return
            }

            guard let sample = samples?.first as? HKQuantitySample else {
                print("⚠️ No resting heart rate sample found.")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            print("✅ Latest resting heart rate:", bpm, "at", sample.endDate)

            let reading = HeartRateReading(bpm: bpm, endDate: sample.endDate)
            DispatchQueue.main.async { completion(reading) }
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
