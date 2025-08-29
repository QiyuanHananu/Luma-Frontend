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
            
            Text("欢迎使用 Luma")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("您的AI健康伴侣")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Luma会24小时关怀您的健康，\n提供个性化的健康建议和情感支持")
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
            
            Text("您的隐私我们守护")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .center, spacing: 15) {
                privacyFeatureRow(icon: "checkmark.seal", text: "所有数据本地加密存储").padding(.horizontal)
                privacyFeatureRow(icon: "eye.slash", text: "绝不与第三方分享个人信息").padding(.horizontal)
                privacyFeatureRow(icon: "shield.checkerboard", text: "符合HIPAA医疗隐私标准").padding(.horizontal)
                privacyFeatureRow(icon: "person.badge.key", text: "您拥有数据的完全控制权").padding(.horizontal)
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
            
            Text("需要您的授权")
                .font(.title)
                .fontWeight(.bold)
            
            Text("为了提供最佳的健康关怀，\nLuma需要访问以下数据：")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 15) {
                permissionRow(icon: "heart", title: "健康数据", description: "心率、步数、睡眠等").padding(.horizontal)
                permissionRow(icon: "mic", title: "麦克风", description: "语音交互和情绪分析").padding(.horizontal)
                permissionRow(icon: "bell", title: "通知", description: "健康提醒和关怀消息").padding(.horizontal)
                permissionRow(icon: "camera", title: "摄像头", description: "面部情绪识别（可选）").padding(.horizontal)
            }
            
            Spacer()
        }
    }
    
    // MARK: - 设置页面
    private var setupPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("个性化设置")
                .font(.title)
                .fontWeight(.bold)
            
            Text("帮助我们更好地了解您")
                .foregroundColor(.secondary)
            
            // 这里将来会添加基础信息表单
            VStack(spacing: 20) {
                Text("年龄范围、健康目标、生活习惯等设置")
                    .foregroundColor(.secondary)
                Text("（具体表单待实现）")
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
                Button("上一步") {
                    withAnimation {
                        currentPage -= 1
                    }
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            // 下一步/完成按钮
            Button(currentPage == totalPages - 1 ? "开始使用" : "下一步") {
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
