//
//  AuthService.swift
//  Luma
//
//  Created by Jiaoyang Liu on 19/1/2026.
//


import Foundation

final class AuthService {
    func login(username: String, password: String) async throws {
        let req = LoginRequest(username: username, password: password)
        let tokens: TokenResponse = try await APIClient.shared.request(
            path: "/api/auth/login/",
            method: "POST",
            body: req,
            requiresAuth: false
        )
        TokenStore.shared.save(access: tokens.access, refresh: tokens.refresh)
    }

    func me() async throws -> MeResponse {
        try await APIClient.shared.request(
            path: "/api/me", 
            method: "GET",
            body: Optional<Int>.none,
            requiresAuth: true
        )
    }
    
    
}
