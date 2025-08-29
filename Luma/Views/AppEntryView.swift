//
//  AppEntryView.swift
//  Luma
//
//  Created by Jiaoyang Liu on 28/8/2025.
//


import SwiftUI

struct AppEntryView: View {
    @State private var hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    @State private var showOnboarding = true

    var body: some View {
            if hasLaunchedBefore {
                CompanionView()
            } else {
                OnboardingView(
                    showOnboarding: $showOnboarding,
                    hasLaunchedBefore: $hasLaunchedBefore
                )
            }
        }
}
