//
//  SimpleMedicalDashboardView.swift
//  Luma
//
// 
//  简化版医疗仪表板，不使用Charts框架以避免崩溃
//

import SwiftUI

// MARK: - 简化医疗仪表板
struct SimpleMedicalDashboardView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部医疗信息
                medicalHeader
                
                // 标签选择器
                tabSelector
                
                // 内容区域
                TabView(selection: $selectedTab) {
                    // 概览
                    overviewContent
                        .tag(0)
                    
                    // 数据记录
                    dataRecordsContent
                        .tag(1)
                    
                    // 设置
                    settingsContent
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
    
    private var medicalHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Medical Dashboard")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Patient ID: LM-2024-001")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // HIPAA合规标识
                HStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.blue)
                    Text("HIPAA")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Quick status indicators
            HStack(spacing: 16) {
                SimpleStatusIndicator(
                    title: "Risk Level",
                    value: "Medium Risk",
                    color: .orange
                )
                
                SimpleStatusIndicator(
                    title: "Health Score",
                    value: "72/100",
                    color: .green
                )
                
                SimpleStatusIndicator(
                    title: "Monitoring",
                    value: "6 Months",
                    color: .blue
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            SimpleTabButton(title: "Overview", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            SimpleTabButton(title: "Data", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            SimpleTabButton(title: "Settings", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private var overviewContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Health overview card
                healthOverviewCard
                
                // Recent activity
                recentActivityCard
                
                // Health trends
                healthTrendsCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var dataRecordsContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Biometric indicators
                biometricDataCard
                
                // Activity records
                activityRecordsCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var settingsContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Privacy settings
                privacySettingsCard
                
                // Data export
                dataExportCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var healthOverviewCard: some View {
        SimpleMedicalCard(title: "Health Overview", icon: "heart.text.square.fill") {
            VStack(spacing: 16) {
                // Health score
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Real-time Health Score")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        HStack(alignment: .bottom, spacing: 4) {
                            Text("72")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("/100")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Simplified health score indicator
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: 0.72)
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                    }
                }
                
                Divider()
                
                // Key indicators
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    SimpleMetricCard(title: "Heart Rate", value: "78 BPM", icon: "heart.fill", color: .red, isNormal: true)
                    SimpleMetricCard(title: "Sleep", value: "65%", icon: "bed.double.fill", color: .blue, isNormal: false)
                    SimpleMetricCard(title: "Stress", value: "7.2/10", icon: "brain.head.profile", color: .orange, isNormal: false)
                    SimpleMetricCard(title: "HRV", value: "42 ms", icon: "waveform.path.ecg", color: .green, isNormal: true)
                }
            }
        }
    }
    
    private var recentActivityCard: some View {
        SimpleMedicalCard(title: "Recent Activity", icon: "clock.fill") {
            VStack(spacing: 12) {
                SimpleActivityItem(
                    title: "Abnormal Stress Level",
                    time: "2 hours ago",
                    status: .warning
                )
                
                SimpleActivityItem(
                    title: "Breathing Exercise Completed",
                    time: "6 hours ago",
                    status: .success
                )
                
                SimpleActivityItem(
                    title: "Sleep Quality Declined",
                    time: "Yesterday",
                    status: .info
                )
            }
        }
    }
    
    private var healthTrendsCard: some View {
        SimpleMedicalCard(title: "Health Trends", icon: "chart.line.uptrend.xyaxis") {
            VStack(spacing: 12) {
                SimpleTrendItem(title: "Sleep Quality", change: -48, description: "Decreased sleep duration")
                SimpleTrendItem(title: "Work Hours", change: +44, description: "Increased overtime frequency")
                SimpleTrendItem(title: "Stress Level", change: +32, description: "Rising work pressure")
                SimpleTrendItem(title: "Exercise Frequency", change: -28, description: "Reduced physical activity")
            }
        }
    }
    
    private var biometricDataCard: some View {
        SimpleMedicalCard(title: "Biometric Data", icon: "waveform.path.ecg") {
            VStack(spacing: 12) {
                Text("Data Summary for Past 7 Days")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    SimpleDataSummary(title: "Avg Heart Rate", value: "76 BPM", trend: .stable)
                    SimpleDataSummary(title: "Avg Sleep", value: "6.8 hours", trend: .down)
                    SimpleDataSummary(title: "Avg Steps", value: "8,200 steps", trend: .up)
                    SimpleDataSummary(title: "Avg Stress", value: "6.5/10", trend: .up)
                }
            }
        }
    }
    
    private var activityRecordsCard: some View {
        SimpleMedicalCard(title: "Activity Records", icon: "list.bullet.clipboard") {
            VStack(spacing: 8) {
                Text("Weekly Activity Statistics")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 8) {
                    SimpleProgressItem(title: "Breathing Exercises", completed: 5, total: 7)
                    SimpleProgressItem(title: "Meditation Practice", completed: 3, total: 7)
                    SimpleProgressItem(title: "Exercise Goals", completed: 4, total: 7)
                    SimpleProgressItem(title: "Sleep Goals", completed: 2, total: 7)
                }
            }
        }
    }
    
    private var privacySettingsCard: some View {
        SimpleMedicalCard(title: "Privacy Settings", icon: "lock.shield.fill") {
            VStack(spacing: 12) {
                SimpleSettingItem(title: "Data Encryption", status: "Enabled", color: .green)
                SimpleSettingItem(title: "Biometric Auth", status: "Enabled", color: .green)
                SimpleSettingItem(title: "Auto Lock", status: "5 minutes", color: .blue)
                SimpleSettingItem(title: "Data Retention", status: "2 years", color: .blue)
            }
        }
    }
    
    private var dataExportCard: some View {
        SimpleMedicalCard(title: "Data Export", icon: "square.and.arrow.up") {
            VStack(spacing: 12) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.blue)
                        Text("Export PDF Report")
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .foregroundColor(.primary)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "tablecells.fill")
                            .foregroundColor(.green)
                        Text("Export CSV Data")
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

// MARK: - 支持组件

struct SimpleStatusIndicator: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

struct SimpleTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .blue : .secondary)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    Rectangle()
                        .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                )
                .overlay(
                    Rectangle()
                        .fill(isSelected ? Color.blue : Color.clear)
                        .frame(height: 2),
                    alignment: .bottom
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SimpleMedicalCard<Content: View>: View {
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

struct SimpleMetricCard: View {
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

struct SimpleActivityItem: View {
    let title: String
    let time: String
    let status: ActivityStatus
    
    enum ActivityStatus {
        case success, warning, info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .warning: return .orange
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: status.icon)
                .foregroundColor(status.color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct SimpleTrendItem: View {
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

struct SimpleDataSummary: View {
    let title: String
    let value: String
    let trend: TrendDirection
    
    enum TrendDirection {
        case up, down, stable
        
        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .stable: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .stable: return .gray
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .foregroundColor(trend.color)
                    .font(.caption)
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct SimpleProgressItem: View {
    let title: String
    let completed: Int
    let total: Int
    
    var progress: Double {
        Double(completed) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(completed)/\(total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progress > 0.7 ? .green : .orange))
        }
        .padding(.vertical, 4)
    }
}

struct SimpleSettingItem: View {
    let title: String
    let status: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 预览
struct SimpleMedicalDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleMedicalDashboardView()
    }
}
