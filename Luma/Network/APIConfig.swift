//
//  APIConfig.swift
//  Luma
//
//  Created by Cursor on 7/3/2026.
//

import Foundation

enum APIConfig {
    // 真机调试请使用电脑局域网 IP，不要使用 127.0.0.1
    static let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String
        ?? "http://172.20.10.2"
}
