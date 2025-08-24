//
//  DigitalTwinView.swift
//  Luma - AI健康伴侣应用
//
//  功能说明：
//  - 用户的数字孪生健康档案页面
//  - 综合展示用户的健康数据和趋势
//  - AI生成的健康洞察和建议
//  - 个性化的健康目标跟踪
//  - 历史健康数据的可视化图表
//
//  主要内容：
//  1. 健康数据概览 - 今日关键指标快照
//  2. 趋势分析图表 - 心率、步数、睡眠等数据变化
//  3. AI健康洞察 - 个性化的健康分析和建议
//  4. 健康目标进度 - 用户设定目标的完成情况
//  5. 健康记录日历 - 按日期查看历史数据
//
//  Created by Han on 23/8/2025.
//

import SwiftUI
import Charts

struct DigitalTwinView: View {
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showingDetailView = false
    @State private var selectedMetric: HealthMetric?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 顶部数字孪生头像
                    digitalTwinHeader
                    
                    // 今日健康概览
                    todayOverviewCard
                    
                    // 时间范围选择器
                    timeRangeSelector
                    
                    // 健康趋势图表
                    healthTrendsSection
                    
                    // AI健康洞察
                    aiInsightsCard
                    
                    // 健康目标进度
                    healthGoalsSection
                    
                    // 健康记录日历
                    healthCalendarSection
                }
                .padding()
            }
            .navigationTitle("我的数字孪生")
            .refreshable {
                await refreshHealthData()
            }
        }
        .sheet(isPresented: $showingDetailView) {
            if let metric = selectedMetric {
                HealthMetricDetailView(metric: metric)
            }
        }
    }
    
    // MARK: - 数字孪生头像部分
    private var digitalTwinHeader: some View {
        VStack(spacing: 15) {
            // 3D数字孪生头像（这里用圆形代替）
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                // 健康状态指示器
                Circle()
                    .stroke(healthStatusColor, lineWidth: 4)
                    .frame(width: 130, height: 130)
                
                // 中心图标
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 5) {
                Text("您的数字健康档案")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(healthStatusText)
                    .font(.subheadline)
                    .foregroundColor(healthStatusColor)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - 今日概览卡片
    private var todayOverviewCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("今日健康概览")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(Date().formatted(.dateTime.month().day().weekday(.wide)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 关键指标网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                HealthOverviewCard(
                    icon: "heart.fill",
                    title: "平均心率",
                    value: "72",
                    unit: "bpm",
                    color: .red,
                    trend: .stable
                )
                
                HealthOverviewCard(
                    icon: "figure.walk",
                    title: "今日步数",
                    value: "8500",
                    unit: "步",
                    color: .green,
                    trend: .up
                )
                
                HealthOverviewCard(
                    icon: "moon.fill",
                    title: "昨夜睡眠",
                    value: "7.5",
                    unit: "小时",
                    color: .purple,
                    trend: .down
                )
                
                HealthOverviewCard(
                    icon: "flame.fill",
                    title: "消耗卡路里",
                    value: "340",
                    unit: "卡",
                    color: .orange,
                    trend: .up
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - 时间范围选择器
    private var timeRangeSelector: some View {
        Picker("时间范围", selection: $selectedTimeRange) {
            Text("今日").tag(TimeRange.day)
            Text("本周").tag(TimeRange.week)
            Text("本月").tag(TimeRange.month)
            Text("3个月").tag(TimeRange.threeMonths)
        }
        .pickerStyle(SegmentedPickerStyle())
        .animation(.easeInOut, value: selectedTimeRange)
    }
    
    // MARK: - 健康趋势图表部分
    private var healthTrendsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("健康趋势")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 20) {
                // 心率趋势图
                healthTrendChart(
                    title: "心率变化",
                    icon: "heart.fill",
                    color: .red,
                    data: []
                )
                
                // 步数趋势图
                healthTrendChart(
                    title: "活动量",
                    icon: "figure.walk",
                    color: .green,
                    data: []
                )
                
                // 睡眠趋势图
                healthTrendChart(
                    title: "睡眠质量",
                    icon: "moon.fill",
                    color: .purple,
                    data: []
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - AI洞察卡片
    private var aiInsightsCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
                Text("AI健康洞察")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("查看更多") {
                    // 显示详细洞察
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(HealthInsight.mockData, id: \.id) { insight in
                    InsightRowSimple(insight: insight)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - 健康目标部分
    private var healthGoalsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("健康目标")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("设置目标") {
                    // 打开目标设置
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                HealthGoalRow(
                    icon: "figure.walk",
                    title: "每日步数",
                    current: 8500,
                    target: 10000,
                    unit: "步"
                )
                
                HealthGoalRow(
                    icon: "moon.fill",
                    title: "睡眠时长",
                    current: 450,
                    target: 480,
                    unit: "分钟"
                )
                
                HealthGoalRow(
                    icon: "drop.fill",
                    title: "饮水量",
                    current: 1800,
                    target: 2000,
                    unit: "ml"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - 健康日历部分
    private var healthCalendarSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("健康记录日历")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("点击日期查看当天详细健康数据")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // 这里将来会添加日历组件
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    Text("健康日历组件\n（待实现）")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - 辅助方法
    private var healthStatusColor: Color {
        return .blue // UI版本：固定为良好状态
    }
    
    private var healthStatusText: String {
        return "健康状态良好" // UI版本：固定显示
    }
    
    private func healthTrendChart(title: String, icon: String, color: Color, data: [HealthDataPoint]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Button("详情") {
                    // 显示详细图表
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            // 简化的图表（这里用矩形代替真实图表）
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
                .frame(height: 80)
                .overlay(
                    Text("趋势图表（待集成Charts框架）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func refreshHealthData() async {
        // UI版本：模拟刷新
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

// MARK: - 枚举定义
enum TimeRange: CaseIterable {
    case day, week, month, threeMonths
}

enum HealthStatus {
    case excellent, good, fair, poor
}

// MARK: - 预览
// MARK: - 简化的洞察行组件
struct InsightRowSimple: View {
    let insight: HealthInsight
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(insight.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("刚刚")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                
                Text("💡 \(insight.suggestion)")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DigitalTwinView()
}
