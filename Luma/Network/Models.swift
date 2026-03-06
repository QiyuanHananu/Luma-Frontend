//
//  LoginRequest.swift
//  Luma
//
//  Created by Jiaoyang Liu on 19/1/2026.
//


import Foundation

struct LoginRequest: Encodable {
    let username: String
    let password: String
}

struct TokenResponse: Decodable {
    let refresh: String
    let access: String
}

// 先按最常见的 /api/me 返回写：id/username/email
// 如果你 curl 出来字段不一样，我们再改成你实际的
struct MeResponse: Decodable {
    let id: Int
    let username: String
    let email: String?
}