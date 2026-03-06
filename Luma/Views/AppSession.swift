//
//  AppSession.swift
//  Luma
//
//  Created by Jiaoyang Liu on 23/1/2026.
//


import SwiftUI

@MainActor
final class AppSession: ObservableObject {
    static let shared = AppSession()

    @Published var isLoggedIn: Bool = false

    private init() {}
}

