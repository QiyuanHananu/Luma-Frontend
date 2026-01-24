//
//  TokenStore.swift
//  Luma
//
//  Created by Jiaoyang Liu on 19/1/2026.
//


import Foundation

final class TokenStore: ObservableObject {
    static let shared = TokenStore()

    @Published private(set) var accessToken: String?
    @Published private(set) var refreshToken: String?

    private init() {
        accessToken = Keychain.read("luma.jwt.access")
        refreshToken = Keychain.read("luma.jwt.refresh")
    }

    func save(access: String, refresh: String) {
        accessToken = access
        refreshToken = refresh
        Keychain.save(access, for: "luma.jwt.access")
        Keychain.save(refresh, for: "luma.jwt.refresh")
    }

    func clear() {
        accessToken = nil
        refreshToken = nil
        Keychain.delete("luma.jwt.access")
        Keychain.delete("luma.jwt.refresh")
    }
}
