//
//  AppEntryView.swift
//  Luma
//
//  Created by Jiaoyang Liu on 28/8/2025.
//

import SwiftUI

struct AppEntryView: View {
    @StateObject private var session = AppSession()

    @State private var hasLaunchedBefore =
        UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    @State private var showOnboarding = true

    var body: some View {
        if !hasLaunchedBefore {
            OnboardingView(
                showOnboarding: $showOnboarding,
                hasLaunchedBefore: $hasLaunchedBefore
            )
        } else if session.isLoggedIn {
            CompanionView()
                .environmentObject(session)
        } else {
            AccountLinkView()
                .environmentObject(session)
        }
    }
}

