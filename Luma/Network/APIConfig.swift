//
//  APIConfig.swift
//  Luma
//
//  Created by Cursor on 7/3/2026.
//

import Foundation

enum APIConfig {
    private static let fallbackBaseURL = "https://luma-backend-9mz4.onrender.com"

    // 模拟器和本机后端在同一台 Mac 上，直接走 127.0.0.1 最稳定。
    // 真机调试时才读取 Info.plist 中的局域网地址。
    static let baseURL: String = {
#if targetEnvironment(simulator)
        return fallbackBaseURL
#else
        let configured = (Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let configured, !configured.isEmpty {
            return configured
        }
        return fallbackBaseURL
#endif
    }()
}

