//
//  ContentView.swift
//  Luma - AI健康伴侣应用
//
//  功能说明：
//  - 应用的主容器视图
//  - 底部标签栏导航
//  - 纯UI版本，包含4个主要页面
//
//  页面结构：
//  1. 伴侣页面 - AI对话界面
//  2. 档案页面 - 健康数据展示
//  3. 技能页面 - 应对技能展示
//  4. 设置页面 - 设置选项
//
//  Created by Han on 23/8/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
            } else {
                mainTabView
            }
        }
        .onAppear {
            // 可以在这里设置是否显示引导页
            showOnboarding = false
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            CompanionView()
                .tabItem {
                    Image(systemName: "heart.circle.fill")
                    Text("Luma")
                }
                .tag(0)
            
            DigitalTwinView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("我的档案")
                }
                .tag(1)
            
            CopingSkillsView()
                .tabItem {
                    Image(systemName: "leaf.circle.fill")
                    Text("应对技能")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear.circle.fill")
                    Text("设置")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}