//
//  AppEntryView.swift
//  Luma
//
//  功能说明：
//  - 应用入口，判断是否首次启动
//  - 首次启动显示 OnboardingView
//  - 之后直接进入 CompanionView（主页面）
//
//  Created by Jiaoyang Liu on 28/8/2025.
//  Updated by Han on 9/10/2025.
//

import SwiftUI

struct AppEntryView: View {
    @State private var hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    @State private var showOnboarding = true

    var body: some View {
        if hasLaunchedBefore {
            // 主页面：CompanionView（带左上角菜单导航）
            CompanionView()
        } else {
            // 首次启动：引导页
            OnboardingView(
                showOnboarding: $showOnboarding,
                hasLaunchedBefore: $hasLaunchedBefore
            )
        }
    }
}

#Preview {
    AppEntryView()
}
