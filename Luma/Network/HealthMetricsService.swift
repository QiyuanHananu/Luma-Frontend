//
//  HealthMetricsService.swift
//  Luma
//

import Foundation

private struct HeartRateUploadRequest: Encodable {
    let heart_rate: Double
    let sample_time: String
    let source: String
}

private struct HRVUploadRequest: Encodable {
    let hrv_sdnn_ms: Double
    let sample_time: String
    let source: String
}

private struct SleepUploadRequest: Encodable {
    let sleep_hours: Double
    let sample_time: String
    let source: String
}

private struct HealthUploadResponse: Decodable {}

final class HealthMetricsService {
    static let shared = HealthMetricsService()
    private init() {}

    func uploadHeartRate(bpm: Double, sampledAt: Date) async {
        let formatter = ISO8601DateFormatter()
        let payload = HeartRateUploadRequest(
            heart_rate: bpm,
            sample_time: formatter.string(from: sampledAt),
            source: "apple_health_watch"
        )

        do {
            let _: HealthUploadResponse = try await APIClient.shared.request(
                path: "/api/health/heart-rate/",
                method: "POST",
                body: payload,
                requiresAuth: true
            )
            print("☁️ Heart rate synced.")
        } catch {
            print("⚠️ Heart rate sync failed:", error.localizedDescription)
        }
    }

    func uploadHRV(sdnnMs: Double, sampledAt: Date) async {
        let formatter = ISO8601DateFormatter()
        let payload = HRVUploadRequest(
            hrv_sdnn_ms: sdnnMs,
            sample_time: formatter.string(from: sampledAt),
            source: "apple_health_watch"
        )

        do {
            let _: HealthUploadResponse = try await APIClient.shared.request(
                path: "/api/health/hrv/",
                method: "POST",
                body: payload,
                requiresAuth: true
            )
            print("☁️ HRV synced.")
        } catch {
            print("⚠️ HRV sync failed:", error.localizedDescription)
        }
    }

    func uploadSleep(hours: Double, sampledAt: Date) async {
        let formatter = ISO8601DateFormatter()
        let payload = SleepUploadRequest(
            sleep_hours: hours,
            sample_time: formatter.string(from: sampledAt),
            source: "apple_health_watch"
        )

        do {
            let _: HealthUploadResponse = try await APIClient.shared.request(
                path: "/api/health/sleep/",
                method: "POST",
                body: payload,
                requiresAuth: true
            )
            print("☁️ Sleep synced.")
        } catch {
            print("⚠️ Sleep sync failed:", error.localizedDescription)
        }
    }
}
