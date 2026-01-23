//
//  TokenStore.swift
//  Luma
//
//  Created by Jiaoyang Liu on 19/1/2026.
//


import Foundation

final class TokenStore {
    static let shared = TokenStore()
    private init() {}

    private let accessKey = "jwt_access"
    private let refreshKey = "jwt_refresh"

    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: accessKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: accessKey) }
    }

    var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: refreshKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: refreshKey) }
    }

    func save(access: String, refresh: String) {
        accessToken = access
        refreshToken = refresh
    }

    func clear() {
        accessToken = nil
        refreshToken = nil
    }
}