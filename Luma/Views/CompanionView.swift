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
import Speech
import AVFoundation
import UIKit
import AudioToolbox

struct CompanionView: View {
    @State private var userInput = ""
    @State private var conversations: [Conversation] = []
    @State private var lumaEmotion: LumaEmotion = .curious
    @State private var showInputArea = true
    @State private var showConversationBubble = false
    @State private var showDigitalTwinView = false
    @State private var showChatHistoryView = false
    @State private var showDashboardView = false
    @State private var showSettingsDialog = false
    @State private var showEmergencyDialog = false
    @State private var showLogoutConfirmation = false
    @State private var isChatFocusMode = false
    @State private var isPressingVoiceInput = false
    @State private var activeRiskAlert: RiskAlertItem?
    @State private var isAwaitingAIReply = false
    @FocusState private var isInputFocused: Bool
    @StateObject private var speechRecognizer = SpeechRecognizer()

    private var isRunningInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    
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
                
            }
            
            .navigationDestination(isPresented: $showDigitalTwinView) {
                        DigitalTwinPage()
                    }
            .navigationDestination(isPresented: $showChatHistoryView) {
                ChatHistoryView()
            }
            .navigationDestination(isPresented: $showDashboardView) {
                DashboardRedesignView()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onTapGesture {
                // 点击空白处隐藏键盘
                hideKeyboard()
            }
            .onChange(of: lumaEmotion) { newValue in
                print("🔄 情绪变化为: \(newValue)")

                }
        }
        .onAppear {
            showInputArea = true
            speechRecognizer.requestAuthorization()

            guard !isRunningInPreview else {
                conversations = []
                activeRiskAlert = nil
                return
            }

            conversations = StorageManager.shared.loadCurrentSession()
            Task {
                await refreshRiskAlertState()
            }
        }
        .onChange(of: speechRecognizer.transcript) { _, newValue in
            userInput = newValue
        }
        .alert("Settings", isPresented: $showSettingsDialog) {
            Button("Logout", role: .destructive) {
                handleLogout()
                showLogoutConfirmation = true
            }

            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Manage your account and current session.")
        }
        .alert("Logged out", isPresented: $showLogoutConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your local conversation state has been cleared for this demo.")
        }
        .alert("Emergency Call", isPresented: $showEmergencyDialog) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This is a demo emergency button. Real calling behavior has not been enabled yet.")
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
            ZStack {
                Text("Luma")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black.opacity(0.88))
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    if isChatFocusMode {
                        Button("Done") {
                            withAnimation(.easeInOut) {
                                isChatFocusMode = false
                                isInputFocused = false
                                showConversationBubble = false
                            }
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color(red: 0.46, green: 0.62, blue: 0.32))
                    }

                    Menu {
                        Button {
                            Task { await startNewConversation() }
                        } label: {
                            Label("Start New Conversation", systemImage: "plus.bubble.fill")
                        }

                        Button {
                            showChatHistoryView = true
                        } label: {
                            Label("View Chat History", systemImage: "clock.arrow.circlepath")
                        }
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
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    .frame(width: 44, height: 44)
                            )
                    }
                    .accessibilityLabel("Chat menu")

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
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    .frame(width: 44, height: 44)
                            )
                    }
                    .accessibilityLabel("Open Digital Twin")

                    Spacer()

                    Button(action: {
                        showDashboardView = true
                    }) {
                        Image(systemName: "square.grid.2x2.fill")
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
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    .frame(width: 44, height: 44)
                            )
                    }
                    .accessibilityLabel("Open Dashboard")

                    Button(action: {
                        showEmergencyDialog = true
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
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    .frame(width: 44, height: 44)
                            )
                    }
                    .accessibilityLabel("Emergency call")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            Spacer()
        }
    }

    

    // MARK: - 历史聊天区（可滚动）
    private var conversationHistoryOverlay: some View {
        Group {
            if (isChatFocusMode || showConversationBubble) && !conversations.isEmpty {
                VStack {
                    conversationArea
                        .padding(.horizontal, 12)
                        .padding(.top, 88)
                        .padding(.bottom, isChatFocusMode ? 96 : 116)
                }
                .transition(.opacity)
                .allowsHitTesting(isChatFocusMode)
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
            TextField("Type or hold the mic to talk with Luma...", text: $userInput, axis: .vertical)
                .focused($isInputFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.black.opacity(0.12), lineWidth: 1)
                )
                .foregroundColor(.black.opacity(0.88))
                .tint(Color(red: 0.46, green: 0.62, blue: 0.32))
                .lineLimit(1...3)
                .onChange(of: isInputFocused) { _, focused in
                    if focused {
                        withAnimation(.easeInOut) {
                            isChatFocusMode = true
                            if !conversations.isEmpty {
                                showConversationBubble = true
                            }
                        }
                    }
                }

            // voice button: hold to speak, release to stop
            ZStack {
                if isPressingVoiceInput {
                    Circle()
                        .stroke(Color(red: 0.78, green: 0.90, blue: 0.62).opacity(0.34), lineWidth: 7)
                        .frame(width: 62, height: 62)
                        .blur(radius: 1.5)
                        .transition(.scale.combined(with: .opacity))
                }

                Circle()
                    .fill(
                        LinearGradient(
                            colors: isPressingVoiceInput ? [
                                Color(red: 0.78, green: 0.90, blue: 0.62).opacity(0.42),
                                Color(red: 0.46, green: 0.62, blue: 0.32).opacity(0.22)
                            ] : [
                                Color.white.opacity(0.26),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                isPressingVoiceInput ? Color(red: 0.78, green: 0.90, blue: 0.62).opacity(0.72) : Color.black.opacity(0.08),
                                lineWidth: isPressingVoiceInput ? 1.8 : 1
                            )
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: speechRecognizer.isRecording ? "waveform" : "mic")
                    .font(.system(size: speechRecognizer.isRecording ? 21 : 20, weight: .semibold))
                    .foregroundColor(speechRecognizer.isRecording ? Color(red: 0.25, green: 0.40, blue: 0.22) : Color(red: 0.46, green: 0.62, blue: 0.32))
            }
            .frame(width: 54, height: 54)
            .scaleEffect(isPressingVoiceInput ? 1.12 : 1.0)
            .shadow(color: isPressingVoiceInput ? Color(red: 0.78, green: 0.90, blue: 0.62).opacity(0.48) : Color.clear, radius: 14, x: 0, y: 0)
            .animation(.spring(response: 0.18, dampingFraction: 0.64), value: isPressingVoiceInput)
            .animation(.easeInOut(duration: 0.16), value: speechRecognizer.isRecording)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressingVoiceInput else { return }
                        isPressingVoiceInput = true
                        triggerVoicePressHaptic()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                            guard isPressingVoiceInput else { return }
                            startVoiceInputIfNeeded()
                        }
                    }
                    .onEnded { _ in
                        isPressingVoiceInput = false
                        stopVoiceInput()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                            triggerVoiceReleaseHaptic()
                        }
                    }
            )
            .accessibilityLabel(speechRecognizer.isRecording ? "Release to stop voice input" : "Hold to start voice input")

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

        // Enter chat mode and keep the input available for continuous conversation.
        withAnimation(.easeInOut) {
            isChatFocusMode = true
            showInputArea = true
            showConversationBubble = true
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
        await MainActor.run {
            StorageManager.shared.clearCurrentSession()
            conversations = []
            activeRiskAlert = nil
            isAwaitingAIReply = false
            userInput = ""
            showInputArea = true
            showConversationBubble = false
            isChatFocusMode = false
            isInputFocused = true
            applySafetyInteraction(for: nil)
        }
    }
    
    private func handleLogout() {
        StorageManager.shared.clearCurrentSession()
        conversations = []
        userInput = ""
        activeRiskAlert = nil
        isAwaitingAIReply = false
        showConversationBubble = false
        isChatFocusMode = false
        isInputFocused = false
        print("🚪 Logout selected from companion settings")
    }

    private func startVoiceInputIfNeeded() {
        guard !speechRecognizer.isRecording else { return }

        lumaEmotion = .curious
        showInputArea = true
        hideKeyboard()

        speechRecognizer.startRecording()
    }

    private func stopVoiceInput() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        }

        userInput = speechRecognizer.transcript
    }

    private func triggerVoicePressHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.prepare()
        impact.impactOccurred(intensity: 1.0)

        let selection = UISelectionFeedbackGenerator()
        selection.prepare()
        selection.selectionChanged()

        AudioServicesPlaySystemSound(1519)
    }

    private func triggerVoiceReleaseHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.prepare()
        impact.impactOccurred(intensity: 1.0)

        let selection = UISelectionFeedbackGenerator()
        selection.prepare()
        selection.selectionChanged()

        AudioServicesPlaySystemSound(1520)
    }
    
    // MARK: - 超大尺寸Luma角色
    private var largeScaleLumaCharacter: some View {
        LumaOrbCharacter(emotion: lumaEmotion)
            .frame(width: 280, height: 280)
    }
    
    private var bottomInputArea: some View {
        VStack {
            Spacer()

            if showInputArea {
                VStack(spacing: 8) {
                    if isPressingVoiceInput {
                        Text("Listening... release to convert to text")
                            .font(.caption.weight(.medium))
                            .foregroundColor(Color(red: 0.46, green: 0.62, blue: 0.32))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.76))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(red: 0.78, green: 0.90, blue: 0.62).opacity(0.55), lineWidth: 1)
                                    )
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // 输入框
                    inputArea
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, isChatFocusMode ? 18 : 10)
                .background(isChatFocusMode ? Color.white : Color.clear)
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, isChatFocusMode ? 0 : 72)
            }
        }
    }
    
    
    // MARK: - 计算属性
    
    private var emotionStatusText: String {
        switch lumaEmotion {
        case .happy: return "I'm very glad to meet you!"
        case .sad: return "I can sense your emotions..."
        case .curious: return "I'm listening carefully..."
        case .tired: return "The battery is a bit low..."
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
                        .fill(Color.black.opacity(0.94))
                        .frame(width: 30, height: 30)
                        .shadow(color: Color(red: 0.46, green: 0.62, blue: 0.32).opacity(0.45), radius: 8, x: 0, y: 0)

                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color(red: 0.25, green: 0.40, blue: 0.22),
                                    Color(red: 0.78, green: 0.90, blue: 0.62),
                                    Color(red: 0.46, green: 0.62, blue: 0.32),
                                    Color(red: 0.78, green: 0.90, blue: 0.62),
                                    Color(red: 0.25, green: 0.40, blue: 0.22)
                                ],
                                center: .center
                            ),
                            lineWidth: 2.4
                        )
                        .frame(width: 21, height: 21)
                        .shadow(color: Color(red: 0.78, green: 0.90, blue: 0.62).opacity(0.55), radius: 5, x: 0, y: 0)

                    Circle()
                        .fill(Color(red: 0.78, green: 0.90, blue: 0.62))
                        .frame(width: 3.2, height: 3.2)
                        .offset(x: 6, y: -6)
                }
                .frame(width: 32, height: 32)

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


private struct ChatHistoryMessage: Identifiable, Decodable {
    let id: Int
    let message: String
    let isFromUser: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case isFromUser = "is_from_user"
        case createdAt = "created_at"
    }
}

struct ChatHistoryView: View {
    @State private var messages: [ChatHistoryMessage] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView("Loading chat history...")
                    Spacer()
                }
            } else if let errorMessage {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Could not load chat history")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            } else if messages.isEmpty {
                Text("No chat history yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(messages) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.isFromUser ? "You" : "Luma")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(item.isFromUser ? .blue : Color(red: 0.46, green: 0.62, blue: 0.32))

                        Text(item.message)
                            .font(.body)
                            .foregroundColor(.primary)

                        Text(item.createdAt)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("Chat History")
        .task {
            await loadHistory()
        }
        .refreshable {
            await loadHistory()
        }
    }

    private func loadHistory() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let result: [ChatHistoryMessage] = try await APIClient.shared.request(
                path: "/api/chat/messages/?limit=100",
                method: "GET",
                body: Optional<Int>.none,
                requiresAuth: true
            )

            await MainActor.run {
                messages = result
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    CompanionView()
        .environmentObject(AppSession.shared)
}

