//
//  MedicalOverviewView.swift
//  Luma
//
//  
//

import SwiftUI
import Charts

// MARK: - 病史概览视图
struct MedicalOverviewView: View {
    let record: MedicalRecord
    @State private var selectedTrendPeriod = "6 Months"
    
    private let trendPeriods = ["1 Month", "3 Months", "6 Months", "1 Year"]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // 临床摘要卡片
                clinicalSummaryCard
                
                // 当前状态卡片
                currentStatusCard
                
                // 趋势图卡片
                trendsCard
                
                // 积极指标卡片
                positiveIndicatorsCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var clinicalSummaryCard: some View {
        MedicalCard(title: "Clinical Summary", icon: "doc.text.fill") {
            VStack(spacing: 16) {
                // 患者基本信息
                InfoRow(label: "Patient ID", value: record.patientId)
                InfoRow(label: "Risk Level", value: record.riskLevel.rawValue, valueColor: record.riskLevel.color)
                InfoRow(label: "Monitoring Period", value: record.monitoringPeriod)
                
                Divider()
                
                // 既往病史
                VStack(alignment: .leading, spacing: 8) {
                    Text("Medical History")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(record.medicalHistory, id: \.self) { condition in
                            ConditionTag(text: condition, color: .orange)
                        }
                    }
                }
                
                // 家族史
                VStack(alignment: .leading, spacing: 8) {
                    Text("Family History")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(record.familyHistory, id: \.self) { condition in
                            ConditionTag(text: condition, color: .purple)
                        }
                    }
                }
            }
        }
    }
    
    private var currentStatusCard: some View {
        MedicalCard(title: "Current Status", icon: "heart.text.square.fill") {
            VStack(spacing: 16) {
                // 健康评分
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Real-time Health Score")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        HStack(alignment: .bottom, spacing: 4) {
                            Text("\(Int(record.currentHealthScore))")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(record.currentHealthScore > 70 ? .green : .orange)
                            
                            Text("/100")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // 健康评分环形图
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: record.currentHealthScore / 100)
                            .stroke(
                                record.currentHealthScore > 70 ? Color.green : Color.orange,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                    }
                }
                
                Divider()
                
                // 关键生理指标
                VStack(spacing: 12) {
                    Text("Key Physiological Indicators")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        MedicalOverviewMetricCard(
                            title: "Heart Rate",
                            value: "\(Int(record.keyMetrics.heartRate)) BPM",
                            icon: "heart.fill",
                            color: .red,
                            isNormal: record.keyMetrics.heartRate >= 60 && record.keyMetrics.heartRate <= 100
                        )
                        
                        MedicalOverviewMetricCard(
                            title: "Sleep Quality",
                            value: "\(Int(record.keyMetrics.sleepQuality))%",
                            icon: "bed.double.fill",
                            color: .blue,
                            isNormal: record.keyMetrics.sleepQuality >= 70
                        )
                        
                        MedicalOverviewMetricCard(
                            title: "Stress Level",
                            value: String(format: "%.1f/10", record.keyMetrics.stressLevel),
                            icon: "brain.head.profile",
                            color: .orange,
                            isNormal: record.keyMetrics.stressLevel <= 5.0
                        )
                        
                        MedicalOverviewMetricCard(
                            title: "HRV",
                            value: "\(Int(record.keyMetrics.hrv)) ms",
                            icon: "waveform.path.ecg",
                            color: .green,
                            isNormal: record.keyMetrics.hrv >= 30
                        )
                    }
                }
            }
        }
    }
    
    private var trendsCard: some View {
        MedicalCard(title: "Health Trends", icon: "chart.line.uptrend.xyaxis") {
            VStack(spacing: 16) {
                // 时间段选择器
                HStack {
                    Text("Trend Analysis")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Picker("Time Period", selection: $selectedTrendPeriod) {
                        ForEach(trendPeriods, id: \.self) { period in
                            Text(period).tag(period)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.caption)
                }
                
                // 模拟趋势数据
                VStack(spacing: 12) {
                    TrendItem(
                        title: "Sleep Quality",
                        change: -48,
                        description: "Decreased sleep duration, insufficient deep sleep"
                    )
                    
                    TrendItem(
                        title: "Work Hours",
                        change: +44,
                        description: "Increased overtime frequency, reduced rest time"
                    )
                    
                    TrendItem(
                        title: "Stress Level",
                        change: +32,
                        description: "Continuous rise in work pressure"
                    )
                    
                    TrendItem(
                        title: "Exercise Frequency",
                        change: -28,
                        description: "Significant reduction in physical activity"
                    )
                }
            }
        }
    }
    
    private var positiveIndicatorsCard: some View {
        MedicalCard(title: "Positive Indicators", icon: "hand.thumbsup.fill") {
            VStack(spacing: 12) {
                PositiveIndicator(
                    title: "Proactive Help-Seeking",
                    value: "15 times",
                    description: "Actively used AI assistant for consultation this month",
                    icon: "questionmark.circle.fill",
                    color: .green
                )
                
                PositiveIndicator(
                    title: "Treatment Engagement",
                    value: "92%",
                    description: "Completed recommended health activities on time",
                    icon: "checkmark.circle.fill",
                    color: .blue
                )
                
                PositiveIndicator(
                    title: "Self-Monitoring",
                    value: "Daily",
                    description: "Consistently records emotional and physical state",
                    icon: "heart.circle.fill",
                    color: .purple
                )
            }
        }
    }
}

// MARK: - 支持组件

struct MedicalCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }
}

struct ConditionTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }
}

struct MedicalOverviewMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let isNormal: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
                
                Image(systemName: isNormal ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(isNormal ? .green : .orange)
                    .font(.caption)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct TrendItem: View {
    let title: String
    let change: Int
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: change > 0 ? "arrow.up" : "arrow.down")
                    .font(.caption)
                    .foregroundColor(change > 0 ? .red : .green)
                
                Text("\(abs(change))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(change > 0 ? .red : .green)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background((change > 0 ? Color.red : Color.green).opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}

struct PositiveIndicator: View {
    let title: String
    let value: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 预览
struct MedicalOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        MedicalOverviewView(record: MedicalRecord(
            patientId: "LM-2024-001",
            riskLevel: .medium,
            monitoringPeriod: "6个月",
            medicalHistory: ["焦虑症", "失眠", "高血压"],
            familyHistory: ["心脏病", "糖尿病"],
            currentHealthScore: 72.5,
            keyMetrics: HealthMetrics(
                heartRate: 78.0,
                sleepQuality: 65.0,
                stressLevel: 7.2,
                hrv: 42.0,
                bloodPressure: "128/82"
            )
        ))
    }
}
