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
    @State private var showHealthSnapshot = false
    @State private var conversations = Conversation.mockData
    @State private var lumaEmotion: LumaEmotion = .curious
    @State private var lumaIsThinking = false
    @State private var showInputArea = false
    @State private var showConversationBubble = false
    @State private var isBouncing = false
    @State private var isDozing = false
    @State private var armsUp = false // Happy时举手
    @State private var armWave = false // 手臂摆动
    @State private var showMedicalDashboard = false // 显示医疗仪表板
    @State private var showDigitalTwinView = false

    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景渐变
                backgroundGradient
                    .ignoresSafeArea()
                
                // 全屏Luma角色
                fullScreenLumaCharacter
                
                // 浮动对话气泡
                if let latestConversation = conversations.last, !conversations.isEmpty {
                    floatingConversationBubble(conversation: latestConversation)
                }
                
                // 顶部控制按钮
                topControls
                
                // 底部输入区域（可隐藏）
                bottomInputArea
                
                // 健康快照（可展开）
                if showHealthSnapshot {
                    healthSnapshotOverlay
                }
            }
            .navigationDestination(isPresented: $showDigitalTwinView) {
                        DigitalTwinPage()
                    }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onTapGesture {
                // 点击空白处隐藏输入框
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
            SimpleMedicalDashboardView()
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
                        showInputArea.toggle()
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
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Tap me to start the conversation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(showInputArea ? 0 : 1)
                        .animation(.easeInOut, value: showInputArea)
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
                Button(action: {
                    withAnimation {
                        showHealthSnapshot.toggle()
                    }
                }) {
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 44, height: 44)
                        )
                }
                
                Spacer()
                
                Text("Luma")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        showMedicalDashboard = true
                    }) {
                        Image(systemName: "stethoscope.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 44, height: 44)
                            )
                    }
                    .accessibilityLabel("医疗仪表板")
                    .accessibilityHint("查看专业医疗数据和分析报告")
                    
                    Button(action: {
                        showDigitalTwinView = true
                    }) {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 44, height: 44)
                            )
                    }

                    
                    Button(action: {
                        // 紧急求助
                    }) {
                        Image(systemName: "phone.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.9))
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
    
    // MARK: - 对话区域
    private var conversationArea: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // 欢迎消息
                if conversations.isEmpty {
                    welcomeMessage
                } else {
                    // 对话记录
                    ForEach(conversations) { conversation in
                        ConversationBubbleSimple(conversation: conversation)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - 健康快照卡片
    private var healthSnapshotCard: some View {
        let healthData = HealthData.mock
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Health Overview")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(Date().formatted(.dateTime.month().day()))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                HealthMetricSimple(
                    icon: "heart.fill",
                    value: "\(healthData.heartRate)",
                    unit: "bpm",
                    color: .red
                )
                
                HealthMetricSimple(
                    icon: "figure.walk",
                    value: "\(healthData.stepCount)",
                    unit: "步",
                    color: .green
                )
                
                HealthMetricSimple(
                    icon: "moon.fill",
                    value: String(format: "%.1f", healthData.sleepHours),
                    unit: "小时",
                    color: .purple
                )
            }
            
            Text("Your condition is great today, keep it up!")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - 输入区域
    private var inputArea: some View {
        // 输入栏
        HStack(spacing: 12) {
            // 文本输入框
            TextField("Have a chat with Luma...", text: $userInput, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(1...3)
                .onSubmit {
                    sendMessage()
                }
            
            // 语音输入按钮
            Button(action: toggleVoiceInput) {
                Circle()
                    .fill(isListening ? Color.red : Color.blue)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "mic.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                    )
                    .scaleEffect(isListening ? 1.2 : 1.0)
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
        VStack(spacing: 15) {
            Text("Let's start our conversation!")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("You can chat with me about health, mood, or anything else you'd like to share")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.blue.opacity(0.1))
        )
        .padding(.horizontal)
    }
    
    // MARK: - 快速回复建议
    private var quickReplySuggestions: some View {
        let suggestions = ["I feel pretty good", "A little bit tired", "I'm very energetic today", "The pressure is a little high", "I need a break"]
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(suggestion) {
                        userInput = suggestion
                        sendMessage()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .font(.caption)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - 背景渐变
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
            showConversationBubble = false
        }
        userInput = ""
        
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
        
        // 显示用户消息气泡
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showConversationBubble = true
            }
        }
        
        // 模拟AI回复
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let aiReply = Conversation(
                message: generateEmotionalResponse(),
                isFromUser: false,
                timestamp: Date()
            )
            
            withAnimation(.spring()) {
                conversations.append(aiReply)
                // 不再强制切换到happy，保持用户触发的情绪
                showConversationBubble = false
            }
            
            // 显示AI回复气泡
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring()) {
                    showConversationBubble = true
                }
            }
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
    
    private func generateEmotionalResponse() -> String {
        switch lumaEmotion {
        case .happy:
            return "It's a great pleasure to chat with you! I noticed that you are in a good mood, which is very beneficial to your health. Is there anything you'd like to share?"
        case .sad:
            return "I sense that you might be a little unhappy. Although I'm just an AI, I want to say that your feelings are very important. Do we need to have a chat?"
        case .curious:
            return "This is very interesting! I want to know more. Could you tell me more details? I will listen carefully."
        case .tired:
            return "My battery is a bit low, but I still want to help you. Perhaps we all need to take a break? Proper rest is very important for health."
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
        ZStack {
            // 角色主体（梨形身体）
            VStack(spacing: -20) {
                // 头部（放大版）
                largeScaleLumaHead
                
                // 身体（放大版）
                largeScaleLumaBody
            }
            .scaleEffect(lumaIsThinking ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: lumaIsThinking)
            if isDozing {
                ZzzOverlay()
                    .offset(x: 60, y: -140)
            }
        }
        .frame(height: 400)
        // 开心：上下弹跳（仅在happy时）
        .offset(y: (lumaEmotion == .happy && isBouncing) ? -20 : 0)
        .animation((lumaEmotion == .happy && isBouncing) ? .spring(response: 0.6, dampingFraction: 0.4).repeatForever(autoreverses: true) : .default, value: isBouncing)
        .onAppear {
            lumaIsThinking = true
            // 根据初始情绪设置动画状态
            switch lumaEmotion {
            case .happy:
                isBouncing = true
                armsUp = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    armWave = true
                }
            case .tired:
                isDozing = true
            case .sad, .curious:
                break // 保持默认状态
            }
        }
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
                    // 快速回复建议
                    quickReplySuggestions
                    
                    // 输入框
                    inputArea
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)
                )
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - 健康快照覆盖层
    private var healthSnapshotOverlay: some View {
        VStack {
            Spacer()
            
            healthSnapshotCard
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
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
                    .rotationEffect(.degrees(armsUp ? (armWave ? -50 : -70) : 15)) // Happy举手+摆动，平时自然垂放
                    .offset(x: armsUp ? -15 : 0, y: armsUp ? -30 : 10)
                
                // 右臂
                Capsule()
                    .fill(Color.white)
                    .frame(width: 30, height: 80)
                    .rotationEffect(.degrees(armsUp ? (armWave ? 50 : 70) : -15)) // Happy举手+摆动，平时自然垂放
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
            if lumaEmotion == .happy {
                EyeArc(smileUp: true)
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 40, height: 24)
            } else if lumaEmotion == .sad {
                EyeArc(smileUp: false)
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
                Circle()
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    )
                
                Text(conversation.message)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(18)
                    .frame(maxWidth: .infinity * 0.7, alignment: .leading)
                
                Spacer()
            }
        }
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
        .environmentObject(AppSession())
}

