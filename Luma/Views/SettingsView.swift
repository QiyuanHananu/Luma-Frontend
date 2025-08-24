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
            .navigationTitle("设置")
        }
        .sheet(isPresented: $showingProfileEdit) {
            ProfileEditView()
        }
        .sheet(isPresented: $showingPrivacySheet) {
            PrivacySettingsView()
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
                        
                        Text("点击编辑个人信息")
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
            Text("个人信息")
        }
    }
    
    // MARK: - AI设置部分
    private var aiSettingsSection: some View {
        Section {
            // AI个性风格
            HStack {
                Label("AI个性风格", systemImage: "brain.head.profile")
                Spacer()
                Text("友好")
                    .foregroundColor(.secondary)
            }
            
            // 语音交互
            HStack {
                Label("语音交互", systemImage: "mic.circle")
                Spacer()
                Toggle("", isOn: $userSettings.voiceEnabled)
                    .labelsHidden()
            }
            
            // 主动关怀
            HStack {
                Label("主动关怀", systemImage: "heart.circle")
                Spacer()
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
            }
            
            // 提醒频率
            HStack {
                Label("关怀频率", systemImage: "clock.circle")
                Spacer()
                Text("适中")
                    .foregroundColor(.secondary)
            }
            
        } header: {
            Text("AI伴侣设置")
        } footer: {
            Text("调整Luma的个性和交互方式，让AI伴侣更符合您的偏好")
        }
    }
    
    // MARK: - 隐私安全部分
    private var privacySection: some View {
        Section {
            // 面部识别
            HStack {
                Label("面部情绪识别", systemImage: "faceid")
                Spacer()
                Toggle("", isOn: $userSettings.faceRecognitionEnabled)
                    .labelsHidden()
            }
            
            // 隐私级别
            HStack {
                Label("隐私级别", systemImage: "shield.checkerboard")
                Spacer()
                Text("平衡")
                    .foregroundColor(.secondary)
            }
            
            // 详细隐私设置
            Button(action: { showingPrivacySheet = true }) {
                HStack {
                    Label("详细隐私设置", systemImage: "lock.shield")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .foregroundColor(.primary)
            
            // 数据导出
            Button("导出我的数据") {
                // 导出用户数据
            }
            .foregroundColor(.blue)
            
        } header: {
            Text("隐私和安全")
        } footer: {
            Text("您的数据安全是我们的首要任务。所有健康数据都经过端到端加密。")
        }
    }
    
    // MARK: - 通知设置部分
    private var notificationSection: some View {
        Section {
            // 推送通知
            HStack {
                Label("推送通知", systemImage: "bell.circle")
                Spacer()
                Toggle("", isOn: $userSettings.notificationsEnabled)
                    .labelsHidden()
            }
            
            // 健康提醒
            HStack {
                Label("健康提醒", systemImage: "heart.text.square")
                Spacer()
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
                    .disabled(!userSettings.notificationsEnabled)
            }
            
            // 运动提醒
            HStack {
                Label("运动提醒", systemImage: "figure.walk.circle")
                Spacer()
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
                    .disabled(!userSettings.notificationsEnabled)
            }
            
            // 睡眠提醒
            HStack {
                Label("睡眠提醒", systemImage: "moon.circle")
                Spacer()
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
                    .disabled(!userSettings.notificationsEnabled)
            }
            
        } header: {
            Text("通知设置")
        } footer: {
            if !userSettings.notificationsEnabled {
                Text("已关闭推送通知，部分功能可能受到限制")
            }
        }
    }
    
    // MARK: - 健康数据部分
    private var healthDataSection: some View {
        Section {
            // HealthKit状态
            HStack {
                Label("HealthKit连接", systemImage: "heart.text.square")
                Spacer()
                
                Text("已连接")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            // 数据同步
            HStack {
                Label("数据同步", systemImage: "arrow.triangle.2.circlepath")
                Spacer()
                
                Text("实时监控中")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            // 健康数据分享
            HStack {
                Label("健康数据共享", systemImage: "square.and.arrow.up")
                Spacer()
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
            }
            
        } header: {
            Text("健康数据")
        } footer: {
            Text("Luma需要访问您的健康数据来提供个性化的健康建议")
        }
    }
    
    // MARK: - 支持部分
    private var supportSection: some View {
        Section {
            NavigationLink(destination: EmptyView()) {
                Label("使用指南", systemImage: "questionmark.circle")
            }
            
            NavigationLink(destination: EmptyView()) {
                Label("常见问题", systemImage: "doc.text")
            }
            
            Button(action: {
                // 联系客服
                if let url = URL(string: "mailto:support@luma.app") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Label("联系客服", systemImage: "envelope")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .foregroundColor(.primary)
            
            NavigationLink(destination: EmptyView()) {
                Label("反馈建议", systemImage: "exclamationmark.bubble")
            }
            
        } header: {
            Text("帮助与支持")
        }
    }
    
    // MARK: - 关于部分
    private var aboutSection: some View {
        Section {
            Button(action: { showingAbout = true }) {
                HStack {
                    Label("关于Luma", systemImage: "info.circle")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .foregroundColor(.primary)
            
            NavigationLink(destination: EmptyView()) {
                Label("隐私政策", systemImage: "hand.raised")
            }
            
            NavigationLink(destination: EmptyView()) {
                Label("服务条款", systemImage: "doc.plaintext")
            }
            
            HStack {
                Label("版本", systemImage: "number")
                Spacer()
                Text("1.0.0 (Beta)")
                    .foregroundColor(.secondary)
            }
            
        } header: {
            Text("关于")
        }
    }
}



// MARK: - 预览
#Preview {
    SettingsView()
}
