//
//  CompanionView.swift
//  Luma - AI健康伴侣应用
//
//  功能说明：
//  - AI伴侣的主要交互界面（根据客户角色设计需求重新设计）
//  - 展示友好的白色机器人Luma角色
//  - 支持情绪表达和动态交互
//  - 纯UI版本，使用模拟数据
//
//  Created by Han on 23/8/2025.
//

import SwiftUI

struct CompanionView: View {
    @State private var userInput = ""
    @State private var isListening = false
    @State private var conversations: [Conversation] = []
    @State private var lumaEmotion: LumaEmotion = .curious
    @State private var lumaIsThinking = false
    @State private var showInputArea = true
    @State private var showConversationBubble = false
    @State private var isBouncing = false
    @State private var isDozing = false
    @State private var armsUp = false // Happy时举手
    @State private var armWave = false // 手臂摆动
    @State private var showMedicalDashboard = false // 显示医疗仪表板
    @State private var showDigitalTwinView = false
    @State private var showDashboard = false
    @State private var isChatFocusMode = false
    @State private var activeRiskAlert: RiskAlertItem?
    @State private var isAwaitingAIReply = false
    
    
    private func generateMockSummary() -> MentalHealthSummary {
        
        guard let first = conversations.first,
              let last = conversations.last else {
            
            return MentalHealthSummary(
                periodStart: Date(),
                periodEnd: Date(),
                moodScore: 5,
                dominantEmotions: ["neutral"],
                riskLevel: "low",
                notes: "No conversation data available."
            )
        }
        
        return MentalHealthSummary(
            periodStart: first.timestamp,
            periodEnd: last.timestamp,
            moodScore: 4,
            dominantEmotions: ["curious"],
            riskLevel: "low",
            notes: "User appears stable during this conversation period."
        )
    }


    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景渐变
                backgroundGradient
                    .ignoresSafeArea()
                
                if !isChatFocusMode {
                    // 全屏Luma角色
                    fullScreenLumaCharacter
                }
                
                // 可滚动历史聊天（覆盖在主界面下方）
                conversationHistoryOverlay
                
                // 顶部控制按钮
                topControls

                topRiskAlertOverlay
                
                // 底部输入区域（可隐藏）
                bottomInputArea
                
                // dashboard
                if !isChatFocusMode {
                    dashboardButtonBottomLeft
                }
            }
            .sheet(isPresented: $showDashboard) {
                    DashboardView()
                        .presentationDetents([.medium])
                }
            .navigationDestination(isPresented: $showDigitalTwinView) {
                        DigitalTwinPage()
                    }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onTapGesture {
                // 点击空白处隐藏键盘
                hideKeyboard()
            }
            .onChange(of: lumaEmotion) { newValue in
                print("🔄 情绪变化为: \(newValue)")
                
                // 立即重置所有动画状态
                isBouncing = false
                isDozing = false
                armsUp = false
                armWave = false
                
                // 根据新情绪设置对应动画
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        switch newValue {
                        case .happy:
                            print("🎉 启动happy动画: 弹跳+举手")
                            isBouncing = true
                            armsUp = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                print("🎉 启动手臂摆动")
                                armWave = true
                            }
                        case .tired:
                            print("😴 启动tired动画: Zzz")
                            isDozing = true
                        case .sad:
                            print("😢 启动sad动画: 坐地低头")
                            // sad的动画通过视图本身的判断实现
                        case .curious:
                            print("🤔 curious状态: 保持默认")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showMedicalDashboard) {
            DashboardRedesignView()
        }
        .onAppear {
            conversations = StorageManager.shared.loadCurrentSession()
            showInputArea = true
            Task {
                await refreshRiskAlertState()
            }
        }
    }
    
    // MARK: - 全屏Luma角色
    private var fullScreenLumaCharacter: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                // 超大Luma角色
                Button(action: {
                    withAnimation(.spring()) {
                        cycleLumaEmotion()
                        showInputArea = true
                        if !conversations.isEmpty {
                            showConversationBubble.toggle()
                        }
                    }
                }) {
                    largeScaleLumaCharacter
                }
                .buttonStyle(PlainButtonStyle())
                
                // Luma状态文字
                VStack(spacing: 10) {
                    Text(emotionStatusText)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black.opacity(0.88))
                        .multilineTextAlignment(.center)
                    
                    Text("Tap me to start conversation")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.black.opacity(0.48))
                }
                .padding(.top, 30)
                
                Spacer()
                Spacer() // 额外的间距，为底部输入区留空间
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // MARK: - 顶部控制按钮
    private var topControls: some View {
        VStack {
            HStack {
                if isChatFocusMode {
                    Button("Done") {
                        withAnimation(.easeInOut) {
                            isChatFocusMode = false
                        }
                    }
                }

                Button {
                    Task { await startNewConversation() }
                } label: {
                    Image(systemName: "plus.bubble.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(red: 0.46, green: 0.62, blue: 0.32))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.14))
                                .frame(width: 44, height: 44)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                .frame(width: 44, height: 44)
                        )
                }
                
                Button(action: {
                    showDigitalTwinView = true
                }) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 22, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .foregroundColor(Color(red: 0.46, green: 0.62, blue: 0.32))
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.14))
                                .frame(width: 44, height: 44)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                .frame(width: 44, height: 44)
                        )
                }
                
                Spacer()
                
                Text("Luma")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black.opacity(0.88))
                
                Spacer()
                
                HStack(spacing: 10) {
                    Button(action: {
                        showMedicalDashboard = true
                    }) {
                        Image(systemName: "stethoscope.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .foregroundColor(Color(red: 0.46, green: 0.62, blue: 0.32))
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.14))
                                    .frame(width: 44, height: 44)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                    .frame(width: 44, height: 44)
                            )
                    }
                    .accessibilityLabel("医疗仪表板")
                    .accessibilityHint("查看专业医疗数据和分析报告")

                    Button(action: {
                        // 紧急求助
                    }) {
                        Image(systemName: "phone.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .foregroundColor(Color(red: 0.78, green: 0.36, blue: 0.32))
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.14))
                                    .frame(width: 44, height: 44)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                    .frame(width: 44, height: 44)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
        }
    }

    
    private var dashboardButtonBottomLeft: some View {
        VStack {
            Spacer()

            HStack {
                Button(action: {
                    showDashboard = true
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(Color(red: 0.46, green: 0.62, blue: 0.32))
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.14))
                                .frame(width: 44, height: 44)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                .frame(width: 44, height: 44)
                        )
                }
                .padding(.leading, 16)
                .padding(.bottom, 20)

                Spacer()
            }
        }
    }

    // MARK: - 历史聊天区（可滚动）
    private var conversationHistoryOverlay: some View {
        Group {
            if showConversationBubble && !conversations.isEmpty {
                VStack {
                    conversationArea
                        .padding(.horizontal, 12)
                        .padding(.top, 88)
                        .padding(.bottom, 116)
                }
                .transition(.opacity)
                .allowsHitTesting(false)
            }
        }
    }
    
    // MARK: - 对话区域
    private var conversationArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    // 对话记录
                    ForEach(conversations) { conversation in
                        ConversationBubbleSimple(conversation: conversation)
                            .id(conversation.id)
                    }
                    
                    if isAwaitingAIReply {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.9)
                            Text("Luma is replying...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .id("typing-indicator")
                    }
                    
                    Color.clear
                        .frame(height: 1)
                        .id("conversation-bottom")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: conversations.count) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo("conversation-bottom", anchor: .bottom)
                }
            }
            .onChange(of: isAwaitingAIReply) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo("conversation-bottom", anchor: .bottom)
                }
            }
            .onAppear {
                proxy.scrollTo("conversation-bottom", anchor: .bottom)
            }
        }
        .background(Color.clear)
    }
    
    
    // MARK: - 输入区域
    private var inputArea: some View {
        // 输入栏
        HStack(spacing: 12) {
            // 文本输入框
            TextField("Have a chat with Luma...", text: $userInput, axis: .vertical)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .foregroundColor(.black.opacity(0.88))
                .tint(Color(red: 0.46, green: 0.62, blue: 0.32))
                .lineLimit(1...3)
                // 不用回车直接发送，避免中文输入法候选未确认时误发。
            
            // 语音输入按钮
            Button(action: toggleVoiceInput) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isListening ? Color(red: 0.78, green: 0.36, blue: 0.32) : Color(red: 0.78, green: 0.90, blue: 0.62))
                    .frame(width: 44, height: 44)
                    .background(Color.clear)
                    .scaleEffect(isListening ? 1.08 : 1.0)
                    .animation(.easeInOut(duration: 0.5), value: isListening)
            }
            
            // 发送按钮
            if !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .transition(.scale)
            }
        }
    }
    
    // MARK: - 欢迎消息
    private var welcomeMessage: some View {
        Text("Tap me to start conversation")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.black.opacity(0.48))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
    }
    
    
    // MARK: - 背景渐变
    private var backgroundGradient: some View {
        Color.white
    }

    private func riskAlertBanner(alert: RiskAlertItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(alert.riskLevel.uppercased() == "HIGH" ? "Safety Alert" : "Wellness Alert")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button {
                    activeRiskAlert = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.9))
                }
                .buttonStyle(.plain)
            }

            Text(alert.alertMessage)
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)

            if let firstAction = alert.recommendedActions.first {
                Text("Suggestion: \(firstAction)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.95))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .foregroundColor(.white)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(alert.riskLevel.lowercased() == "high" ? Color.red.opacity(0.92) : Color.orange.opacity(0.9))
        )
    }

    private var topRiskAlertOverlay: some View {
        VStack {
            if let alert = activeRiskAlert {
                riskAlertBanner(alert: alert)
                    .padding(.horizontal, 12)
                    .padding(.top, 76)
            }
            Spacer()
        }
        .zIndex(50)
    }
    
    // MARK: - 方法
    private func sendMessage() {
        let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let userMessage = Conversation(
            message: trimmed,
            isFromUser: true,
            timestamp: Date()
        )
        
        withAnimation {
            conversations.append(userMessage)
            showConversationBubble = true
        }
        StorageManager.shared.saveMessage(userMessage)
        Task {
            await ChatService.shared.upload(conversation: userMessage)
        }
        userInput = ""
        
        // invoke AI model
        isAwaitingAIReply = true
        Task {
            do {
                let reply = try await fetchAIReply(message: userMessage.message)

                let aiMessage = Conversation(
                    message: reply,
                    isFromUser: false,
                    timestamp: Date()
                )

                await MainActor.run {
                    conversations.append(aiMessage)
                    StorageManager.shared.saveMessage(aiMessage)
                }
                await ChatService.shared.upload(conversation: aiMessage)
                await refreshRiskAlertState()

            } catch {
                print("❌ AI error:", error)
                let fallback = Conversation(
                    message: "I could not fetch a reply right now. Please check your network or backend server and try again.",
                    isFromUser: false,
                    timestamp: Date()
                )
                await MainActor.run {
                    conversations.append(fallback)
                    StorageManager.shared.saveMessage(fallback)
                }
            }
            await MainActor.run {
                isAwaitingAIReply = false
            }
        }
        
        // 隐藏输入区域
        withAnimation(.spring()) {
            showInputArea = false
        }
        
        // 关键词触发情绪（happy/sad/tired）
        let lower = trimmed.lowercased()
        if lower.contains("happy") || lower.contains("开心") || lower.contains("高兴") {
            print("🎉 设置情绪为: happy")
            lumaEmotion = .happy
        } else if lower.contains("sad") || lower.contains("难过") || lower.contains("伤心") {
            print("😢 设置情绪为: sad")
            lumaEmotion = .sad
        } else if lower.contains("tired") || lower.contains("困") || lower.contains("zzz") || lower.contains("困了") {
            print("😴 设置情绪为: tired")
            lumaEmotion = .tired
        } else {
            print("🤔 设置情绪为: curious")
            // 未命中关键词：进入好奇倾听
            lumaEmotion = .curious
        }
        
        // Keep chat bubbles visible after sending. Users can tap the orb to hide/show them.
        withAnimation {
            showConversationBubble = true
        }
    }
    
    private func cycleLumaEmotion() {
        withAnimation(.spring()) {
            let allEmotions = LumaEmotion.allCases
            if let currentIndex = allEmotions.firstIndex(of: lumaEmotion) {
                let nextIndex = (currentIndex + 1) % allEmotions.count
                lumaEmotion = allEmotions[nextIndex]
            }
        }
    }
    
    func fetchAIReply(message: String) async throws -> String {

        let body = [
            "message": message
        ]

        let response: AIReplyResponse = try await APIClient.shared.request(
            path: "/api/chat-with-ai/",
            method: "POST",
            body: body,
            requiresAuth: true
        )

        return response.reply
    }

    private func refreshRiskAlertState() async {
        // Risk alert has been replaced by proactive tracking on the dashboard.
        // Keep this as a no-op so the companion page no longer calls the old
        // /api/alerts/risk/ endpoint.
        await MainActor.run {
            activeRiskAlert = nil
            applySafetyInteraction(for: nil)
        }
    }

    private func startNewConversation() async {
        do {
            let _: NewChatSessionResponse = try await APIClient.shared.request(
                path: "/api/chat/new-session/",
                method: "POST",
                body: Optional<Int>.none,
                requiresAuth: true
            )
            await MainActor.run {
                StorageManager.shared.clearCurrentSession()
                conversations = []
                activeRiskAlert = nil
                isAwaitingAIReply = false
                showInputArea = true
                showConversationBubble = false
                isChatFocusMode = false
                applySafetyInteraction(for: nil)
            }
        } catch {
            let fallback = Conversation(
                message: "Could not start a new session right now. Please try again.",
                isFromUser: false,
                timestamp: Date()
            )
            await MainActor.run {
                conversations.append(fallback)
                StorageManager.shared.saveMessage(fallback)
            }
        }
    }
    
    private func toggleVoiceInput() {
        withAnimation {
            isListening.toggle()
        }
        
        // 模拟语音输入
        if isListening {
            lumaEmotion = .curious
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isListening = false
                userInput = "Content just entered via voice input"
                // 不再强制设置为happy，保持curious状态
            }
        }
    }
    
    // MARK: - 超大尺寸Luma角色
    private var largeScaleLumaCharacter: some View {
        LumaOrbCharacter(emotion: lumaEmotion)
            .frame(width: 280, height: 280)
    }
    
    // MARK: - 浮动对话气泡
    private func floatingConversationBubble(conversation: Conversation) -> some View {
        GeometryReader { geometry in
            if conversation.isFromUser {
                // 用户消息气泡 - 放在右上角
                HStack {
                    Spacer()
                    userBubbleView(conversation: conversation)
                        .offset(x: -30, y: geometry.size.height * 0.15)
                }
            } else {
                // Luma回复气泡 - 放在左侧中间偏上，避开身体
                HStack {
                    lumaBubbleView(conversation: conversation)
                        .offset(x: 30, y: geometry.size.height * 0.3)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .opacity(showConversationBubble ? 1 : 0)
        .scaleEffect(showConversationBubble ? 1 : 0.5)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showConversationBubble)
        .onAppear {
            withAnimation(.spring().delay(0.3)) {
                showConversationBubble = true
            }
            
            // 5秒后自动隐藏用户消息气泡（给用户更多时间阅读）
            if conversation.isFromUser {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation(.spring()) {
                        showConversationBubble = false
                    }
                }
            } else {
                // AI消息显示更长时间
                DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                    withAnimation(.spring()) {
                        showConversationBubble = false
                    }
                }
            }
        }
    }
    
    // MARK: - 用户消息气泡
    private func userBubbleView(conversation: Conversation) -> some View {
        HStack {
            Text(conversation.message)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                )
                .foregroundColor(.white)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 220)
            
            // 气泡指向尾巴（指向右侧用户）
            Path { path in
                path.move(to: CGPoint(x: 0, y: 10))
                path.addLine(to: CGPoint(x: 15, y: 20))
                path.addLine(to: CGPoint(x: 0, y: 30))
                path.closeSubpath()
            }
            .fill(Color.blue)
            .frame(width: 15, height: 40)
        }
    }
    
    // MARK: - Luma消息气泡
    private func lumaBubbleView(conversation: Conversation) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // 气泡指向尾巴（指向左侧Luma）
            Path { path in
                path.move(to: CGPoint(x: 15, y: 10))
                path.addLine(to: CGPoint(x: 0, y: 20))
                path.addLine(to: CGPoint(x: 15, y: 30))
                path.closeSubpath()
            }
            .fill(Color(.systemGray6))
            .frame(width: 15, height: 40)
            .offset(y: 8)
            
            VStack(alignment: .leading, spacing: 8) {
                // 小Luma头像标识
                HStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color(.systemGray5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 20, height: 20)
                        .overlay(
                            HStack(spacing: 2) {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 3, height: 3)
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 3, height: 3)
                            }
                        )
                    
                    Text("Luma")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                // 消息内容
                Text(conversation.message)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                    )
                    .foregroundColor(.primary)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: 280, alignment: .leading)
    }
    
    // MARK: - 底部输入区域
    private var bottomInputArea: some View {
        VStack {
            Spacer()
            
            if showInputArea {
                VStack(spacing: 15) {
                    // 输入框
                    inputArea
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.clear)
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, isChatFocusMode ? 26 : 72)
            }
        }
    }
    
    
    // MARK: - 放大版Luma头部
    private var largeScaleLumaHead: some View {
        ZStack {
            // 头部基础形状（椭圆形）
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(.systemGray6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160, height: 200)
                .overlay(
                    // 头部高光
                    Ellipse()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 60, height: 80)
                        .offset(x: -30, y: -40)
                )
            
            // 眼睛（放大版）
            largeScaleLumaEyes
            
            // 内部发光效果（基于情绪）
            Circle()
                .fill(
                    RadialGradient(
                        colors: [emotionGlowColor.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .opacity(glowOpacity)
                .animation(.easeInOut(duration: emotionAnimationDuration).repeatForever(autoreverses: true), value: lumaIsThinking)
        }
        // 负面情绪：低头
        .rotationEffect(lumaEmotion == .sad ? Angle(degrees: 12) : .degrees(0))
        .offset(y: lumaEmotion == .sad ? 18 : 0)
    }
    
    // MARK: - 放大版Luma身体
    private var largeScaleLumaBody: some View {
        ZStack {
            // 身体主体（梨形 - 用椭圆模拟）
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(.systemGray5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 240, height: 280)
                .overlay(
                    // 身体高光
                    Ellipse()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 80, height: 120)
                        .offset(x: -40, y: -60)
                )
            
            // 手臂（根据情绪变化）
            HStack(spacing: 280) {
                // 左臂
                Capsule()
                    .fill(Color.white)
                    .frame(width: 30, height: 80)
                    .rotationEffect(.degrees(armsUp ? (armWave ? -50 : -70) : 15))
                    .offset(x: armsUp ? -15 : 0, y: armsUp ? -30 : 10)
                
                // 右臂
                Capsule()
                    .fill(Color.white)
                    .frame(width: 30, height: 80)
                    .rotationEffect(.degrees(armsUp ? (armWave ? 50 : 70) : -15))
                    .offset(x: armsUp ? 15 : 0, y: armsUp ? -30 : 10)
            }
            .offset(y: -40) // 手臂位置调整
            .animation((lumaEmotion == .happy && armsUp) ? .spring(response: 0.8, dampingFraction: 0.6) : .spring(response: 0.6), value: armsUp)
            .animation((lumaEmotion == .happy && armWave) ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: armWave)
            
            // 短腿（stubby legs）
            HStack(spacing: 60) {
                // 左腿
                Capsule()
                    .fill(Color.white)
                    .frame(width: 40, height: 60)
                    .offset(y: lumaEmotion == .sad ? 80 : 110) // Sad时腿部收起
                
                // 右腿
                Capsule()
                    .fill(Color.white)
                    .frame(width: 40, height: 60)
                    .offset(y: lumaEmotion == .sad ? 80 : 110) // Sad时腿部收起
            }
        }
        .offset(y: lumaEmotion == .sad ? 60 : 0) // Sad时整体坐低
        .scaleEffect(lumaEmotion == .sad ? 0.9 : 1.0)
        .animation(.spring(), value: lumaEmotion)
    }
    
    // MARK: - 放大版Luma眼睛
    private var largeScaleLumaEyes: some View {
        HStack(spacing: 24) {
            // 左眼
            largeScaleLumaEye
            
            // 右眼
            largeScaleLumaEye
        }
        .offset(y: -20)
    }
    
    private var largeScaleLumaEye: some View {
        ZStack {
            if lumaEmotion == .sad {
                EyeArc(smileUp: false)
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 40, height: 24)
            } else if lumaEmotion == .happy {
                EyeArc(smileUp: true)
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 40, height: 24)
            } else if lumaEmotion == .tired {
                // 困倦：闭眼（横线）
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 30, height: 4)
                    .cornerRadius(2)
            } else {
                Circle()
                    .fill(Color.black)
                    .frame(width: eyeWidth * 2, height: eyeHeight * 2)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: lumaEmotion)
    }
    
    // MARK: - Luma眼睛（根据情绪变化）
    private var lumaEyes: some View {
        HStack(spacing: 12) {
            // 左眼
            lumaEye
            
            // 右眼
            lumaEye
        }
        .offset(y: -10)
    }
    
    private var lumaEye: some View {
        ZStack {
            if lumaEmotion == .happy {
                EyeArc(smileUp: true)
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: eyeWidth + 10, height: 12)
            } else if lumaEmotion == .sad {
                EyeArc(smileUp: false)
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: eyeWidth + 10, height: 12)
            } else if lumaEmotion == .tired {
                // 困倦：闭眼（横线）
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 20, height: 2)
                    .cornerRadius(1)
            } else {
                Circle()
                    .fill(Color.black)
                    .frame(width: eyeWidth, height: eyeHeight)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: lumaEmotion)
    }
    
    // MARK: - Luma身体
    private var lumaBody: some View {
        ZStack {
            // 身体主体（梨形 - 用椭圆模拟）
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(.systemGray5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 120, height: 140)
                .overlay(
                    // 身体高光
                    Ellipse()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 40, height: 60)
                        .offset(x: -20, y: -30)
                )
            
            // 短腿（stubby legs）
            HStack(spacing: 30) {
                // 左腿
                Capsule()
                    .fill(Color.white)
                    .frame(width: 20, height: 30)
                    .offset(y: lumaEmotion == .sad ? 35 : 55)
                
                // 右腿
                Capsule()
                    .fill(Color.white)
                    .frame(width: 20, height: 30)
                    .offset(y: lumaEmotion == .sad ? 35 : 55)
            }
        }
        // 坐下效果：整体下移并略缩小
        .offset(y: lumaEmotion == .sad ? 30 : 0)
        .scaleEffect(lumaEmotion == .sad ? 0.95 : 1.0)
    }
    
    // MARK: - Luma状态文字
    private var lumaStatusText: some View {
        VStack(spacing: 5) {
            Text(emotionStatusText)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("Tap to start the conversation")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.bottom)
    }
    
    // MARK: - 计算属性
    private var eyeWidth: CGFloat {
        switch lumaEmotion {
        case .happy: return 12
        case .sad: return 8
        case .curious: return 15
        case .tired: return 10
        }
    }
    
    private var eyeHeight: CGFloat {
        switch lumaEmotion {
        case .happy: return 12
        case .sad: return 8
        case .curious: return 12
        case .tired: return 6
        }
    }
    
    private var emotionStatusText: String {
        switch lumaEmotion {
        case .happy: return "I'm very glad to meet you!"
        case .sad: return "I can sense your emotions..."
        case .curious: return "I'm listening carefully..."
        case .tired: return "The battery is a bit low..."
        }
    }
    
    private var emotionGlowColor: Color {
        switch lumaEmotion {
        case .happy: return .blue
        case .sad: return .gray
        case .curious: return .green
        case .tired: return .orange
        }
    }
    
    private var glowOpacity: Double {
        switch lumaEmotion {
        case .happy: return lumaIsThinking ? 0.8 : 0.4
        case .sad: return 0.2
        case .curious: return lumaIsThinking ? 0.9 : 0.6
        case .tired: return lumaIsThinking ? 0.3 : 0.1
        }
    }
    
    private var emotionAnimationDuration: Double {
        switch lumaEmotion {
        case .happy: return 1.5
        case .sad: return 3.0
        case .curious: return 1.0
        case .tired: return 4.0
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func applySafetyInteraction(for alert: RiskAlertItem?) {
        _ = alert
    }
    
    
}


// MARK: - Luma情绪枚举
enum LumaEmotion: CaseIterable {
    case happy
    case sad
    case curious
    case tired
}

// MARK: - Zzz 漂浮标识
struct ZzzOverlay: View {
    @State private var up: Bool = false
    @State private var opacity: Double = 0.3
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Z")
                .font(.headline)
                .opacity(opacity + 0.5)
                .offset(y: up ? -15 : 0)
            Text("z")
                .font(.title3)
                .opacity(opacity + 0.3)
                .offset(y: up ? -10 : 0)
            Text("z")
                .font(.caption)
                .opacity(opacity + 0.1)
                .offset(y: up ? -5 : 0)
        }
        .foregroundColor(.gray)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: up)
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: opacity)
        .onAppear {
            up = true
            opacity = 0.8
        }
    }
}

// MARK: - 眼睛弧线（开心月牙/倒月牙）
struct EyeArc: Shape {
    let smileUp: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        if smileUp {
            // 开心月牙：向上弯曲（笑眼）
            path.addArc(
                center: CGPoint(x: center.x, y: center.y + radius * 0.2),
                radius: radius,
                startAngle: .degrees(200),
                endAngle: .degrees(340),
                clockwise: false
            )
        } else {
            // 悲伤倒月牙：向下弯曲（哭眼）- 倒过来的弧
            path.addArc(
                center: CGPoint(x: center.x, y: center.y - radius * 0.4),
                radius: radius * 0.8,
                startAngle: .degrees(200),
                endAngle: .degrees(340),
                clockwise: true
            )
        }
        return path
    }
}

// MARK: - 简化的对话气泡
struct ConversationBubbleSimple: View {
    let conversation: Conversation
    
    var body: some View {
        HStack {
            if conversation.isFromUser {
                Spacer()
                
                Text(conversation.message)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(18)
                    .frame(maxWidth: .infinity * 0.7, alignment: .trailing)
            } else {
                ZStack {
                    Circle()
                        .stroke(Color(red: 0.78, green: 0.90, blue: 0.62).opacity(0.65), lineWidth: 5)
                        .frame(width: 30, height: 30)
                        .blur(radius: 1.2)

                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color(red: 0.25, green: 0.40, blue: 0.22).opacity(0.55),
                                    Color(red: 0.78, green: 0.90, blue: 0.62).opacity(0.95),
                                    Color(red: 0.46, green: 0.62, blue: 0.32).opacity(0.90),
                                    Color(red: 0.78, green: 0.90, blue: 0.62).opacity(0.85),
                                    Color(red: 0.25, green: 0.40, blue: 0.22).opacity(0.55)
                                ],
                                center: .center
                            ),
                            lineWidth: 2.4
                        )
                        .frame(width: 24, height: 24)
                        .shadow(color: Color(red: 0.46, green: 0.62, blue: 0.32).opacity(0.28), radius: 4, x: 0, y: 0)

                    Circle()
                        .fill(Color(red: 0.78, green: 0.90, blue: 0.62).opacity(0.85))
                        .frame(width: 3.5, height: 3.5)
                        .offset(x: 7, y: -7)
                }
                .frame(width: 30, height: 30)

                Text(conversation.message)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .frame(maxWidth: .infinity * 0.7, alignment: .leading)
                Spacer()
            }
        }
    }
}

// MARK: - High-tech glowing orb character
struct LumaOrbCharacter: View {
    let emotion: LumaEmotion

    private var accentColor: Color {
        Color(red: 0.46, green: 0.62, blue: 0.32)
    }

    private var lightGreen: Color {
        Color(red: 0.78, green: 0.90, blue: 0.62)
    }

    private var deepGreen: Color {
        Color(red: 0.25, green: 0.40, blue: 0.22)
    }

    var body: some View {
        ZStack {
            // Outer soft glow, tinted by emotion but still mostly white.
            Circle()
                .stroke(lightGreen.opacity(0.18), lineWidth: 22)
                .frame(width: 228, height: 228)
                .blur(radius: 22)

            // Main white luminous ring, inspired by an eclipse-like orb.
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            deepGreen.opacity(0.42),
                            lightGreen.opacity(0.78),
                            accentColor.opacity(0.82),
                            lightGreen.opacity(0.88),
                            deepGreen.opacity(0.46)
                        ],
                        center: .center
                    ),
                    lineWidth: 4.2
                )
                .frame(width: 220, height: 220)
                .shadow(color: lightGreen.opacity(0.36), radius: 9, x: 0, y: 0)
                .shadow(color: accentColor.opacity(0.30), radius: 14, x: 0, y: 0)

            // Very subtle inner haze; no solid background fill.
            Circle()
                .stroke(lightGreen.opacity(0.16), lineWidth: 18)
                .frame(width: 194, height: 194)
                .blur(radius: 18)

            // Small highlight on the rim.
            Circle()
                .fill(lightGreen.opacity(0.86))
                .frame(width: 10, height: 10)
                .blur(radius: 1.2)
                .offset(x: 72, y: -72)
                .shadow(color: lightGreen.opacity(0.46), radius: 10, x: 0, y: 0)
                .shadow(color: accentColor.opacity(0.40), radius: 16, x: 0, y: 0)

            // Sparse particles around the ring.
            ForEach(0..<10, id: \.self) { index in
                let angle = Double(index) / 10.0 * 360.0 + 14.0
                let radius = CGFloat(105 + (index % 3) * 6)
                Circle()
                    .fill((index % 2 == 0 ? lightGreen : accentColor).opacity(index % 2 == 0 ? 0.58 : 0.38))
                    .frame(width: CGFloat(index % 2 == 0 ? 3 : 2), height: CGFloat(index % 2 == 0 ? 3 : 2))
                    .offset(x: cos(angle * .pi / 180) * radius, y: sin(angle * .pi / 180) * radius)
                    .shadow(color: accentColor.opacity(0.45), radius: 5, x: 0, y: 0)
            }

        }
        .frame(width: 280, height: 280)
    }
}

struct OrbLooseArc: Shape {
    let width: CGFloat
    let height: CGFloat
    let rotation: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let arcRect = CGRect(
            x: center.x - width / 2,
            y: center.y - height / 2,
            width: width,
            height: height
        )

        path.addEllipse(in: arcRect)
        return path.applying(CGAffineTransform(translationX: -center.x, y: -center.y))
            .applying(CGAffineTransform(rotationAngle: rotation * .pi / 180))
            .applying(CGAffineTransform(translationX: center.x, y: center.y))
    }
}

// MARK: - 简化的健康指标
struct HealthMetricSimple: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CompanionView()
        .environmentObject(AppSession.shared)
}

