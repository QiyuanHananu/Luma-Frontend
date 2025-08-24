//
//  HealthComponents.swift
//  Luma - AI健康伴侣应用
//
//  功能说明：
//  - 健康相关的UI组件集合（纯UI版本）
//  - 可复用的健康数据展示组件
//  - 使用模拟数据，不包含复杂业务逻辑
//
//  Created by Han on 23/8/2025.
//

import SwiftUI

// MARK: - 健康概览卡片
struct HealthOverviewCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    let trend: HealthTrend
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
                
                // 趋势指示器
                HStack(spacing: 2) {
                    Image(systemName: trendIcon)
                        .font(.caption2)
                        .foregroundColor(trendColor)
                    
                    Text(trendText)
                        .font(.caption2)
                        .foregroundColor(trendColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var trendIcon: String {
        switch trend {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "minus"
        }
    }
    
    private var trendColor: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .stable: return .gray
        }
    }
    
    private var trendText: String {
        switch trend {
        case .up: return "上升"
        case .down: return "下降"
        case .stable: return "稳定"
        }
    }
}

// MARK: - 健康目标行
struct HealthGoalRow: View {
    let icon: String
    let title: String
    let current: Int
    let target: Int
    let unit: String
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }
    
    private var progressColor: Color {
        switch progress {
        case 0.8...1.0: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(progressColor)
                    .frame(width: 20)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(current)/\(target) \(unit)")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .foregroundColor(progressColor)
                }
            }
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    // 进度
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .cornerRadius(3)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - AI洞察行
struct InsightRow: View {
    let insight: HealthInsight
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 严重程度指示器
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                // 标题和时间
                HStack {
                    Text(insight.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(insight.timestamp.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // 描述
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                
                // 建议
                if !insight.suggestion.isEmpty {
                    Text("💡 \(insight.suggestion)")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                
                // 相关指标标签（UI版本：显示固定标签）
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        Text("睡眠")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                        
                        Text("健康")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 健康指标详情视图
struct HealthMetricDetailView: View {
    let metric: HealthMetric
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 指标概览
                    metricOverview
                    
                    // 今日数据
                    todayDataSection
                    
                    // 趋势图表
                    trendChartSection
                    
                    // 目标设置
                    goalSection
                    
                    // AI建议
                    aiRecommendationSection
                }
                .padding()
            }
            .navigationTitle(metric.displayName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var metricOverview: some View {
        VStack(spacing: 16) {
            // 大图标和当前值
            VStack(spacing: 8) {
                Image(systemName: metric.icon)
                    .font(.system(size: 60))
                    .foregroundColor(metric.color)
                
                Text("72") // 示例数值
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(metric.unit)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // 状态描述
            Text("当前状态：正常范围")
                .font(.headline)
                .foregroundColor(.green)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(20)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var todayDataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日数据")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                DataPoint(title: "最高值", value: "85", color: .red)
                DataPoint(title: "最低值", value: "62", color: .blue)
                DataPoint(title: "平均值", value: "72", color: .green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var trendChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7天趋势")
                .font(.headline)
                .fontWeight(.semibold)
            
            // 图表占位符
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    Text("趋势图表\n（待集成Charts框架）")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("目标设置")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("编辑") {
                    // 编辑目标
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            HealthGoalRow(
                icon: metric.icon,
                title: "每日目标",
                current: 7200,
                target: 10000,
                unit: metric.unit
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var aiRecommendationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
                Text("AI建议")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("基于您的数据分析")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("您的\(metric.displayName)数据在正常范围内。建议继续保持当前的生活习惯，适量运动有助于维持健康的\(metric.displayName)。")
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - 数据点组件
struct DataPoint: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - 健康状态指示器
struct HealthStatusIndicator: View {
    let status: HealthStatus
    let size: CGFloat
    
    init(status: HealthStatus, size: CGFloat = 100) {
        self.status = status
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(Color(.systemGray5), lineWidth: size * 0.08)
            
            // 状态圆环
            Circle()
                .trim(from: 0, to: statusProgress)
                .stroke(
                    statusColor,
                    style: StrokeStyle(
                        lineWidth: size * 0.08,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: statusProgress)
            
            // 中心图标和文字
            VStack(spacing: size * 0.05) {
                Image(systemName: statusIcon)
                    .font(.system(size: size * 0.25))
                    .foregroundColor(statusColor)
                
                Text(statusText)
                    .font(.system(size: size * 0.12, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: size, height: size)
    }
    
    private var statusProgress: Double {
        switch status {
        case .excellent: return 1.0
        case .good: return 0.8
        case .fair: return 0.6
        case .poor: return 0.3
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        }
    }
    
    private var statusIcon: String {
        switch status {
        case .excellent: return "checkmark.circle.fill"
        case .good: return "heart.circle.fill"
        case .fair: return "exclamationmark.circle.fill"
        case .poor: return "xmark.circle.fill"
        }
    }
    
    private var statusText: String {
        switch status {
        case .excellent: return "极佳"
        case .good: return "良好"
        case .fair: return "一般"
        case .poor: return "需改善"
        }
    }
}

// MARK: - 呼吸练习视图（占位符）
struct BreathingExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("呼吸练习功能")
                    .font(.title)
                Text("（待实现）")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("深呼吸")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 日记视图（占位符）
struct JournalView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("情绪日记功能")
                    .font(.title)
                Text("（待实现）")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("情绪日记")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 个人资料编辑视图（占位符）
struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("个人资料编辑")
                    .font(.title)
                Text("（待实现）")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("编辑资料")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 隐私设置视图（占位符）
struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("隐私设置")
                    .font(.title)
                Text("（待实现）")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("隐私设置")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 关于视图（占位符）
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("关于Luma")
                    .font(.title)
                Text("（待实现）")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("关于")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 预览
#Preview("Health Overview Card") {
    HealthOverviewCard(
        icon: "heart.fill",
        title: "心率",
        value: "72",
        unit: "bpm",
        color: .red,
        trend: .stable
    )
    .padding()
}

#Preview("Health Goal Row") {
    HealthGoalRow(
        icon: "figure.walk",
        title: "每日步数",
        current: 7500,
        target: 10000,
        unit: "步"
    )
    .padding()
}

#Preview("Health Status Indicator") {
    HealthStatusIndicator(status: .good, size: 120)
}
