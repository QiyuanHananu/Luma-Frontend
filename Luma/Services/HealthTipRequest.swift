//
//  HealthTipRequest.swift
//  Luma
//
//  Created by Jiaoyang Liu on 21/5/2026.
//


import Foundation

struct HealthTipRequest: Encodable {
    let metric: String
    let value: Double?
    let status: String
    let context: String?
}

struct HealthTipResponse: Decodable {
    let tip: String
    let fallbackTip: String?
    let source: String?

    enum CodingKeys: String, CodingKey {
        case tip
        case fallbackTip = "fallback_tip"
        case source
    }
}

enum HealthTipService {
    static func generateTip(
        metric: String,
        value: Double?,
        status: String,
        context: String? = nil
    ) async throws -> String {
        let response: HealthTipResponse = try await APIClient.shared.request(
            path: "/api/health/tip/",
            method: "POST",
            body: HealthTipRequest(
                metric: metric,
                value: value,
                status: status,
                context: context
            ),
            requiresAuth: false
        )

        return response.tip
    }
}