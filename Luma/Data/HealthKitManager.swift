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
            let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount),
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        else {
            print("❌ Failed to create one or more HealthKit data types.")
            completion?(false)
            return
        }

        let readTypes: Set<HKObjectType> = [heartRateType, stepCountType, sleepType]

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
            let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount),
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        else {
            print("⚠️ Unable to build HealthKit types for status snapshot.")
            return
        }

        let heartStatus = healthStore.authorizationStatus(for: heartRateType)
        let stepsStatus = healthStore.authorizationStatus(for: stepCountType)
        let sleepStatus = healthStore.authorizationStatus(for: sleepType)

        print("🩺 HealthKit status snapshot - heartRate: \(heartStatus.readable), stepCount: \(stepsStatus.readable), sleep: \(sleepStatus.readable)")
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
