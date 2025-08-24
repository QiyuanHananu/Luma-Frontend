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
        case .heartRate: return "心率"
        case .stepCount: return "步数"
        case .sleep: return "睡眠"
        case .calories: return "卡路里"
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
        case .stepCount: return "步"
        case .sleep: return "小时"
        case .calories: return "卡"
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
            title: "睡眠质量改善",
            description: "您的睡眠质量在过去一周有所改善",
            suggestion: "继续保持规律的作息时间",
            timestamp: Date().addingTimeInterval(-3600)
        ),
        HealthInsight(
            title: "运动量提醒",
            description: "今天的活动量比平时少了30%",
            suggestion: "建议进行30分钟的轻度运动",
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
            title: "4-7-8呼吸法",
            description: "经典的放松呼吸练习",
            duration: 5,
            icon: "wind",
            color: .blue
        ),
        CopingSkill(
            title: "正念冥想",
            description: "专注当下，观察呼吸",
            duration: 10,
            icon: "leaf.fill",
            color: .green
        ),
        CopingSkill(
            title: "感恩日记",
            description: "记录值得感恩的事情",
            duration: 10,
            icon: "heart.fill",
            color: .pink
        ),
        CopingSkill(
            title: "肌肉放松",
            description: "逐步放松全身肌肉",
            duration: 15,
            icon: "figure.mind.and.body",
            color: .purple
        )
    ]
}

/// 用户设置
class UserSettings: ObservableObject {
    @Published var userName = "用户"
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
            message: "今天感觉有点累，可能是昨晚没睡好",
            isFromUser: true,
            timestamp: Date().addingTimeInterval(-300)
        ),
        Conversation(
            message: "我理解您的感受。看看您的睡眠数据，昨晚确实只睡了6.5小时。建议今晚早点休息，保持7-8小时的睡眠。",
            isFromUser: false,
            timestamp: Date().addingTimeInterval(-240)
        ),
        Conversation(
            message: "好的，我会注意的。有什么改善睡眠的建议吗？",
            isFromUser: true,
            timestamp: Date().addingTimeInterval(-180)
        ),
        Conversation(
            message: "建议睡前1小时避免使用电子设备，可以尝试一些放松练习，比如深呼吸或轻度冥想。",
            isFromUser: false,
            timestamp: Date().addingTimeInterval(-120)
        )
    ]
}
