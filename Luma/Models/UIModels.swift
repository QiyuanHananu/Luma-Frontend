//
//  UIModels.swift
//  Luma - AI健康伴侣应用
//
//  功能说明：
//  - 纯UI版本的简化数据模型
//  - 只包含界面展示需要的基础数据结构
//  - 不包含复杂的业务逻辑和API集成
//
//  Created by Han on 23/8/2025.
//

import SwiftUI
import Foundation

// MARK: - 基础数据模型

/// 对话消息
struct Conversation: Identifiable {
    let id = UUID()
    let message: String
    let isFromUser: Bool
    let timestamp: Date
    
    var formattedTime: String {
        timestamp.formatted(.dateTime.hour().minute())
    }
}

/// 健康数据
struct HealthData {
    let heartRate: Int
    let stepCount: Int
    let sleepHours: Double
    let calories: Int
    
    static let mock = HealthData(
        heartRate: 72,
        stepCount: 8500,
        sleepHours: 7.5,
        calories: 340
    )
}

/// 健康数据点（用于图表）
struct HealthDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    
    var formattedDate: String {
        date.formatted(.dateTime.month().day())
    }
}

/// 健康指标
enum HealthMetric: String, CaseIterable {
    case heartRate = "heart_rate"
    case stepCount = "step_count"
    case sleep = "sleep"
    case calories = "calories"
    
    var displayName: String {
        switch self {
        case .heartRate: return "Heart Rate"
        case .stepCount: return "Step Count"
        case .sleep: return "Sleep Hours"
        case .calories: return "Calories"
        }
    }
    
    var icon: String {
        switch self {
        case .heartRate: return "heart.fill"
        case .stepCount: return "figure.walk"
        case .sleep: return "moon.fill"
        case .calories: return "flame.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .heartRate: return .red
        case .stepCount: return .green
        case .sleep: return .purple
        case .calories: return .orange
        }
    }
    
    var unit: String {
        switch self {
        case .heartRate: return "bpm"
        case .stepCount: return "steps"
        case .sleep: return "hours"
        case .calories: return "calories"
        }
    }
}

/// 健康趋势
enum HealthTrend {
    case up, down, stable
}

/// AI洞察
struct HealthInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let suggestion: String
    let timestamp: Date
    
    static let mockData = [
        HealthInsight(
            title: "Better Sleep This Week ❤️",
            description: "You've been sleeping better over the past week. That's a great sign 👍",
            suggestion: "Keep up your healthy routine — your body is thanking you for it ☁️",
            timestamp: Date().addingTimeInterval(-3600)
        ),
        HealthInsight(
            title: "Gentle Nudge to Move 👟",
            description: "Looks like you've been a bit less active today — about 30 % below your usual 🫂",
            suggestion: "Maybe take a short walk or stretch for 30 minutes? Your future self will thank you 🙏",
            timestamp: Date().addingTimeInterval(-1800)
        )
    ]
}

/// 应对技能
struct CopingSkill: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let duration: Int // 分钟
    let icon: String
    let color: Color
    
    static let mockData = [
        CopingSkill(
            title: "4-7-8 Breathing",
            description: "Let’s breathe together. Inhale for 4, hold for 7, exhale for 8. Gently reset 🧘",
            duration: 5,
            icon: "wind",
            color: .blue
        ),
        CopingSkill(
            title: "Mindfulness Meditation",
            description: "Let’s take a moment to be here, just as we are",
            duration: 10,
            icon: "leaf.fill",
            color: .green
        ),
        CopingSkill(
            title: "Gratitude Journaling",
            description: "Even one small thing — let’s write it down and hold onto that feeling",
            duration: 10,
            icon: "heart.fill",
            color: .pink
        ),
        CopingSkill(
            title: "Progressive Muscle Relaxation",
            description: "We’ll go slowly. From your toes to your shoulders, let’s release the tension together",
            duration: 15,
            icon: "figure.mind.and.body",
            color: .purple
        )
    ]
}

/// 用户设置
class UserSettings: ObservableObject {
    @Published var userName = "user"
    @Published var notificationsEnabled = true
    @Published var voiceEnabled = true
    @Published var faceRecognitionEnabled = false
    
    static let shared = UserSettings()
}

// MARK: - 模拟数据

/// 模拟对话数据
extension Conversation {
    static let mockData = [
        Conversation(
            message: "I feel a bit tired today. Maybe I didn’t sleep well last night.",
            isFromUser: true,
            timestamp: Date().addingTimeInterval(-300)
        ),
        Conversation(
            message: "I hear you. Based on your recent sleep data, you slept 6.5 hours last night. I suggest turning in earlier tonight to get 7–8 hours of rest 🛌",
            isFromUser: false,
            timestamp: Date().addingTimeInterval(-240)
        ),
        Conversation(
            message: "Alright. I'll keep that in mind. Do you have any tips for better sleep?",
            isFromUser: true,
            timestamp: Date().addingTimeInterval(-180)
        ),
        Conversation(
            message: "Try limiting screen time an hour before bed. You could also try relaxing techniques like deep breathing or mindfulness 🎧",
            isFromUser: false,
            timestamp: Date().addingTimeInterval(-120)
        )
    ]
}
