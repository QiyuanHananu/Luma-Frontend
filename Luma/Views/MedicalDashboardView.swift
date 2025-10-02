//
//  MedicalDashboardView.swift
//  Luma
//
// 
//

import SwiftUI
import Charts

// MARK: - 医疗数据模型
struct MedicalRecord {
    let patientId: String
    let riskLevel: RiskLevel
    let monitoringPeriod: String
    let medicalHistory: [String]
    let familyHistory: [String]
    let currentHealthScore: Double
    let keyMetrics: HealthMetrics
}

struct HealthMetrics {
    let heartRate: Double
    let sleepQuality: Double
    let stressLevel: Double
    let hrv: Double
    let bloodPressure: String
}

enum RiskLevel: String, CaseIterable {
    case low = "Low Risk"
    case medium = "Medium Risk"
    case high = "High Risk"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

struct TimelineEvent {
    let id = UUID()
    let date: Date
    let title: String
    let description: String
    let severity: EventSeverity
    let category: EventCategory
}

enum EventSeverity: String, CaseIterable {
    case crisis = "Crisis"
    case warning = "Warning"
    case success = "Success"
    case normal = "Normal"
    
    var color: Color {
        switch self {
        case .crisis: return .red
        case .warning: return .orange
        case .success: return .green
        case .normal: return .blue
        }
    }
}

enum EventCategory: String, CaseIterable {
    case intervention = "Intervention"
    case pattern = "Pattern Discovery"
    case crisis = "Crisis Event"
    case recovery = "Recovery"
}

// MARK: - 主医疗界面
struct MedicalDashboardView: View {
    @State private var selectedTab = 0
    @State private var medicalRecord = MedicalRecord(
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
    )
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部导航
                medicalHeader
                
                // 标签页选择器
                tabSelector
                
                // 内容区域
                TabView(selection: $selectedTab) {
                    MedicalOverviewView(record: medicalRecord)
                        .tag(0)
                    
                    TimelineView()
                        .tag(1)
                    
                    BiometricDataView()
                        .tag(2)
                    
                    BehavioralPatternsView()
                        .tag(3)
                    
                    ExportSharingView()
                        .tag(4)
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
                
                Text("Patient ID: \(medicalRecord.patientId)")
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
            
            // 快速状态指示器
            HStack(spacing: 16) {
                StatusIndicator(
                    title: "Risk Level",
                    value: medicalRecord.riskLevel.rawValue,
                    color: medicalRecord.riskLevel.color
                )
                
                StatusIndicator(
                    title: "Health Score",
                    value: "\(Int(medicalRecord.currentHealthScore))/100",
                    color: medicalRecord.currentHealthScore > 70 ? .green : .orange
                )
                
                StatusIndicator(
                    title: "Monitoring Period",
                    value: medicalRecord.monitoringPeriod,
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                TabButton(title: "Overview", icon: "chart.bar.fill", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                TabButton(title: "Timeline", icon: "timeline.selection", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                TabButton(title: "Biometric Data", icon: "waveform.path.ecg", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                
                TabButton(title: "Behavioral Patterns", icon: "brain.head.profile", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
                
                TabButton(title: "Export & Share", icon: "square.and.arrow.up", isSelected: selectedTab == 4) {
                    selectedTab = 4
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
        .background(Color(.systemBackground))
    }
}

// MARK: - 状态指示器组件
struct StatusIndicator: View {
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

// MARK: - 标签按钮组件
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .blue : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 预览
struct MedicalDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MedicalDashboardView()
    }
}
