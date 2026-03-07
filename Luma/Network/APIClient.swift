//
//  APIClient.swift
//  Luma
//
//  Created by Jiaoyang Liu on 19/1/2026.
//


import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case http(Int, String)
    case decode
    case noAccessToken

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .http(let code, let body): return "HTTP \(code): \(body)"
        case .decode: return "Failed to decode JSON"
        case .noAccessToken: return "No access token"
        }
    }
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let baseURL = APIConfig.baseURL

    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {

        guard let url = URL(string: baseURL + path) else { throw APIError.invalidURL }
        print("🌐 Request URL:", url.absoluteString)
        print("➡️ Request Method:", method)
        
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.timeoutInterval = 15
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            guard let token = TokenStore.shared.accessToken else { throw APIError.noAccessToken }
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            req.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        let data: Data
        let resp: URLResponse
        do {
            (data, resp) = try await URLSession.shared.data(for: req)
        } catch {
            if let urlError = error as? URLError {
                print("❌ Network error:", urlError.code.rawValue, urlError.localizedDescription)
            } else {
                print("❌ Request failed:", error.localizedDescription)
            }
            throw error
        }
        guard let http = resp as? HTTPURLResponse else { throw APIError.http(-1, "No response") }
        print("⬅️ Response Status:", http.statusCode)

        if !(200...299).contains(http.statusCode) {
            let text = String(data: data, encoding: .utf8) ?? ""
            print("❌ Response Body:", text)
            throw APIError.http(http.statusCode, text)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decode
        }
    }
}

private struct AnyEncodable: Encodable {
    let wrapped: Encodable
    init(_ wrapped: Encodable) { self.wrapped = wrapped }
    func encode(to encoder: Encoder) throws { try wrapped.encode(to: encoder) }
}
