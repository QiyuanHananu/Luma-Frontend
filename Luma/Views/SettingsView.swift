//
//  SettingsView.swift
//  Luma - AI健康伴侣应用
//
//  功能说明：
//  - 应用设置和用户偏好配置页面
//  - 隐私和安全设置管理
//  - AI伴侣个性化配置
//  - 健康数据权限管理
//  - 账户信息和支持服务
//
//  设置分类：
//  1. 个人信息 - 用户档案和基本信息
//  2. AI设置 - 伴侣个性和交互偏好
//  3. 隐私安全 - 数据权限和加密设置
//  4. 通知提醒 - 推送和主动关怀设置
//  5. 健康数据 - HealthKit权限和数据管理
//  6. 帮助支持 - 使用指南和客服联系
//
//  Created by Han on 23/8/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var userSettings = UserSettings.shared
    @State private var showingProfileEdit = false
    @State private var showingPrivacySheet = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                // 用户档案部分
                profileSection
                
                // AI设置部分
                aiSettingsSection
                
                // 隐私和安全部分
                privacySection
                
                // 通知设置部分
                notificationSection
                
                // 健康数据部分
                healthDataSection
                
                // 帮助和支持部分
                supportSection
                
                // 关于部分
                aboutSection
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingProfileEdit) {
            ProfileView()
        }
        .sheet(isPresented: $showingPrivacySheet) {
            PrivacySecurityView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    // MARK: - 用户档案部分
    private var profileSection: some View {
        Section {
            Button(action: { showingProfileEdit = true }) {
                HStack {
                    // 用户头像
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(userSettings.userName.prefix(1).uppercased())
                                .foregroundColor(.white)
                                .font(.title2)
                                .fontWeight(.semibold)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(userSettings.userName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Tap to edit personal information")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .buttonStyle(PlainButtonStyle())
        } header: {
            Text("Personal Information")
        }
    }
    
    // MARK: - AI设置部分
    private var aiSettingsSection: some View {
        Section {
            // AI个性风格
            HStack {
                Label("AI Personality", systemImage: "brain.head.profile")
                Spacer()
                Text("Friendly")
                    .foregroundColor(.secondary)
            }
            
            // 语音交互
            HStack {
                Label("Voice Interaction", systemImage: "mic.circle")
                Spacer()
                Toggle("", isOn: $userSettings.voiceEnabled)
                    .labelsHidden()
            }
            
            // 主动关怀
            HStack {
                Label("Proactive Care", systemImage: "heart.circle")
                Spacer()
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
            }
            
            // 提醒频率
            HStack {
                Label("Care Frequency", systemImage: "clock.circle")
                Spacer()
                Text("Moderate")
                    .foregroundColor(.secondary)
            }
            
        } header: {
            Text("AI Companion Settings")
        } footer: {
            Text("Adjust Luma’s personality and interaction style to better match your preferences")
        }
    }
    
    // MARK: - 隐私安全部分
    private var privacySection: some View {
        Section {
            // 面部识别
            HStack {
                Label("Facial Emotion Recognition", systemImage: "faceid")
                Spacer()
                Toggle("", isOn: $userSettings.faceRecognitionEnabled)
                    .labelsHidden()
            }
            
            // 隐私级别
            HStack {
                Label("Privacy Level", systemImage: "shield.checkerboard")
                Spacer()
                Text("Balanced")
                    .foregroundColor(.secondary)
            }
            
            // 详细隐私设置
            Button(action: { showingPrivacySheet = true }) {
                HStack {
                    Label("Detailed Privacy Settings", systemImage: "lock.shield")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .foregroundColor(.primary)
            
            // 数据导出
            Button("Export my data") {
                // 导出用户数据
            }
            .foregroundColor(.blue)
            
        } header: {
            Text("Privacy and Security")
        } footer: {
            Text("Your data security is our top priority. All health data is end-to-end encrypted.")
        }
    }
    
    // MARK: - 通知设置部分
    private var notificationSection: some View {
        Section {
            // 推送通知
            HStack {
                Label("Push Notification", systemImage: "bell.circle")
                Spacer()
                Toggle("", isOn: $userSettings.notificationsEnabled)
                    .labelsHidden()
            }
            
            // 健康提醒
            HStack {
                Label("Health Reminders", systemImage: "heart.text.square")
                Spacer()
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
                    .disabled(!userSettings.notificationsEnabled)
            }
            
            // 运动提醒
            HStack {
                Label("Exercise Reminders", systemImage: "figure.walk.circle")
                Spacer()
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
                    .disabled(!userSettings.notificationsEnabled)
            }
            
            // 睡眠提醒
            HStack {
                Label("Sleep Reminders", systemImage: "moon.circle")
                Spacer()
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
                    .disabled(!userSettings.notificationsEnabled)
            }
            
        } header: {
            Text("Notification Settings")
        } footer: {
            if !userSettings.notificationsEnabled {
                Text("Push notifications are disabled. Some features may be limited.")
            }
        }
    }
    
    // MARK: - 健康数据部分
    private var healthDataSection: some View {
        Section {
            // HealthKit状态
            HStack {
                Label("HealthKit Connected", systemImage: "heart.text.square")
                Spacer()
                
                Text("Connected")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            // 数据同步
            HStack {
                Label("Data Sync", systemImage: "arrow.triangle.2.circlepath")
                Spacer()
                
                Text("Real-Time Monitoring")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            // 健康数据分享
            HStack {
                Label("Share Health Data", systemImage: "square.and.arrow.up")
                Spacer()
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
            }
            
        } header: {
            Text("Health Data")
        } footer: {
            Text("Luma needs access to your health data to provide personalized health advice")
        }
    }
    
    // MARK: - 支持部分
    private var supportSection: some View {
        Section {
            NavigationLink(destination: EmptyView()) {
                Label("User Guide", systemImage: "questionmark.circle")
            }
            
            NavigationLink(destination: EmptyView()) {
                Label("FAQ", systemImage: "doc.text")
            }
            
            Button(action: {
                // 联系客服
                if let url = URL(string: "mailto:support@luma.app") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Label("Contact Support", systemImage: "envelope")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .foregroundColor(.primary)
            
            NavigationLink(destination: EmptyView()) {
                Label("Feedback", systemImage: "exclamationmark.bubble")
            }
            
        } header: {
            Text("Help & Support")
        }
    }
    
    // MARK: - 关于部分
    private var aboutSection: some View {
        Section {
            Button(action: { showingAbout = true }) {
                HStack {
                    Label("About Luma", systemImage: "info.circle")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .foregroundColor(.primary)
            
            NavigationLink(destination: EmptyView()) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            
            NavigationLink(destination: EmptyView()) {
                Label("Terms of Service", systemImage: "doc.plaintext")
            }
            
            HStack {
                Label("Version", systemImage: "number")
                Spacer()
                Text("1.0.0 (Beta)")
                    .foregroundColor(.secondary)
            }
            
        } header: {
            Text("About")
        }
    }
}



// MARK: - 预览
#Preview {
    SettingsView()
}
