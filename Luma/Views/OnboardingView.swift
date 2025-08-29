//
//  OnboardingView.swift
//  Luma - AI健康伴侣应用
//
//  功能说明：
//  - 用户首次使用时的引导页面
//  - 介绍Luma的核心功能和价值
//  - 获取必要的用户权限（健康数据、通知等）
//  - 设置用户的基础健康信息和偏好
//  - 创建个性化的AI伴侣设置
//
//  流程步骤：
//  1. 欢迎页面 - 介绍Luma
//  2. 隐私说明 - 解释数据安全
//  3. 权限请求 - 健康数据访问
//  4. 基础设置 - 用户信息录入
//  5. AI个性化 - 选择伴侣风格
//
//  Created by Han on 23/8/2025.
//

import SwiftUI

struct OnboardingView: View {
    // MARK: - 绑定属性
    @Binding var showOnboarding: Bool
    @State private var showCompanionView = false
    @Binding var hasLaunchedBefore: Bool
    
    // MARK: - 状态管理
    @State private var currentPage = 0
    @State private var isCompleted = false
    
    
    
    // MARK: - 页面总数
    private let totalPages = 5
    
    var body: some View {
        VStack {
            // 顶部进度指示器
            progressIndicator
            
            // 主要内容区域
            TabView(selection: $currentPage) {
                // 页面1：欢迎
                welcomePage
                    .tag(0)
                
                // 页面2：隐私说明
                privacyPage
                    .tag(1)
                
                // 页面3：权限请求
                permissionsPage
                    .tag(2)
                
                // 页面4：基础设置
                setupPage
                    .tag(3)
                
                // 页面5：完成设置
                completionPage
                    .tag(4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // 底部导航按钮
            navigationButtons
        }
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - 进度指示器
    private var progressIndicator: some View {
        HStack {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index <= currentPage ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
                    .animation(.easeInOut, value: currentPage)
            }
        }
        .padding(.top, 50)
    }
    
    // MARK: - 欢迎页面
    private var welcomePage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Luma Logo
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome to Luma")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your AI Health Companion")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Luma is here to care for your health 24/7,\nproviding personalized health advice and emotional support.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - 隐私页面
    private var privacyPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("We protect your privacy")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .center, spacing: 15) {
                privacyFeatureRow(icon: "checkmark.seal", text: "Encrypted Data").padding(.horizontal)
                privacyFeatureRow(icon: "eye.slash", text: "No Data Sharing").padding(.horizontal)
                privacyFeatureRow(icon: "shield.checkerboard", text: "HIPAA Compliant").padding(.horizontal)
                privacyFeatureRow(icon: "person.badge.key", text: "User Data Control").padding(.horizontal)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
    
    // MARK: - 权限页面
    private var permissionsPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Full Data Control")
                .font(.title)
                .fontWeight(.bold)
            
            Text("To provide the best health care,\nLuma needs access to the following data:")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 15) {
                permissionRow(icon: "heart", title: "Health Data", description: "Heart rate, steps, sleep, etc.").padding(.horizontal)
                permissionRow(icon: "mic", title: "Microphone", description: "Voice interaction and emotion analysis").padding(.horizontal)
                permissionRow(icon: "bell", title: "Notifications", description: "Health alerts and care messages").padding(.horizontal)
                permissionRow(icon: "camera", title: "Camera", description: "Facial emotion recognition (optional)").padding(.horizontal)
            }
            
            Spacer()
        }
    }
    
    // MARK: - 设置页面
    private var setupPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Personalized Setup")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Help Us Know You Better")
                .foregroundColor(.secondary)
            
            // 这里将来会添加基础信息表单
            VStack(spacing: 20) {
                Text("Age, Goals, Habits")
                    .foregroundColor(.secondary)
                Text("(Form Coming Soon)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
    
    // MARK: - 完成页面
    private var completionPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("设置完成！")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Luma已经准备好为您提供\n24小时的健康关怀服务")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    // MARK: - 底部导航按钮
    private var navigationButtons: some View {
        HStack {
            // 上一步按钮
            if currentPage > 0 {
                Button("Previous") {
                    withAnimation {
                        currentPage -= 1
                    }
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            // 下一步/完成按钮
            Button(currentPage == totalPages - 1 ? "Start" : "Next") {
                if currentPage == totalPages - 1 {
                    completeOnboarding()
                } else {
                    withAnimation {
                        currentPage += 1
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(25)
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 50)
    }
    
    // MARK: - 辅助方法
    private func privacyFeatureRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 30)
            Text(text)
            Spacer()
        }
    }
    
    private func permissionRow(icon: String, title: String, description: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        withAnimation {
            hasLaunchedBefore = true
        }
    }
}

// MARK: - 预览
#Preview {
    OnboardingView(
        showOnboarding: .constant(true),
        hasLaunchedBefore: .constant(false)
    )
}
