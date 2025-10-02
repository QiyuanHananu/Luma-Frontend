//
//  BiometricDataView.swift
//  Luma
//
//  
//

import SwiftUI
import Charts

// MARK: - 生物数据模型
struct BiometricData {
    let id = UUID()
    let date: Date
    let heartRate: Double
    let hrv: Double
    let sleepQuality: Double
    let stressLevel: Double
    let bloodPressureSystolic: Double
    let bloodPressureDiastolic: Double
    let cortisolLevel: Double // 皮质醇估算
    let recoveryScore: Double // 恢复评分
}

struct BiometricRange {
    let min: Double
    let max: Double
    let optimal: ClosedRange<Double>
    
    func status(for value: Double) -> BiometricStatus {
        if optimal.contains(value) {
            return .normal
        } else if value < optimal.lowerBound {
            return .low
        } else {
            return .high
        }
    }
}

enum BiometricStatus {
    case normal, low, high
    
    var color: Color {
        switch self {
        case .normal: return .green
        case .low: return .blue
        case .high: return .red
        }
    }
    
    var description: String {
        switch self {
        case .normal: return "正常"
        case .low: return "偏低"
        case .high: return "偏高"
        }
    }
}

// MARK: - 生物数据记录视图
struct BiometricDataView: View {
    @State private var selectedMetric: BiometricMetric = .heartRate
    @State private var selectedTimeRange: BiometricTimeRange = .week
    @State private var biometricData: [BiometricData] = []
    @State private var showRawData = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 控制面板
            controlPanel
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    // 交互式图表
                    interactiveChart
                    
                    // 医疗级指标卡片
                    medicalMetricsGrid
                    
                    // 恢复跟踪
                    recoveryTrackingCard
                    
                    // 原始数据表格（可选显示）
                    if showRawData {
                        rawDataTable
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .onAppear {
            loadBiometricData()
        }
    }
    
    private var controlPanel: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Biometric Data Analysis")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { showRawData.toggle() }) {
                        HStack(spacing: 4) {
                            Image(systemName: showRawData ? "chart.bar.fill" : "tablecells.fill")
                            Text(showRawData ? "Charts" : "Data")
                        }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            // 指标选择器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(BiometricMetric.allCases, id: \.self) { metric in
                        MetricButton(
                            metric: metric,
                            isSelected: selectedMetric == metric
                        ) {
                            selectedMetric = metric
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Time range selector
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(BiometricTimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private var interactiveChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(selectedMetric.displayName) Trends")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("6 Months Data")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 图表区域
            chartView
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            
            // 正常范围指示器
            if let range = selectedMetric.normalRange {
                HStack {
                    Text("Normal Range: \(range.optimal.lowerBound, specifier: "%.1f") - \(range.optimal.upperBound, specifier: "%.1f") \(selectedMetric.unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var medicalMetricsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Medical-Grade Indicators")
                .font(.headline)
                .fontWeight(.semibold)
            
            medicalMetricsGridContent
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var recoveryTrackingCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Recovery Tracking")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 12) {
                RecoveryIndicator(
                    title: "Overall Recovery Ability",
                    score: 78,
                    description: "Comprehensive ability to recover from stress"
                )
                
                RecoveryIndicator(
                    title: "Sleep Recovery",
                    score: 85,
                    description: "Efficiency of physical recovery through sleep"
                )
                
                RecoveryIndicator(
                    title: "Heart Rate Recovery",
                    score: 72,
                    description: "Speed of heart rate return to normal after exercise"
                )
                
                RecoveryIndicator(
                    title: "Stress Recovery",
                    score: 65,
                    description: "Psychological recovery ability after stress events"
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var rawDataTable: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Raw Data Table")
                .font(.headline)
                .fontWeight(.semibold)
            
            rawDataTableContent
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var rawDataTableContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 0) {
                // 表头
                tableHeader
                
                // 数据行
                ForEach(Array(filteredData.enumerated()), id: \.element.id) { index, data in
                    tableDataRow(data: data, index: index)
                }
            }
        }
    }
    
    private var tableHeader: some View {
        HStack(spacing: 0) {
                        TableHeaderCell(text: "Date", width: 100)
                        TableHeaderCell(text: "Heart Rate", width: 80)
                        TableHeaderCell(text: "HRV", width: 80)
                        TableHeaderCell(text: "Sleep", width: 80)
                        TableHeaderCell(text: "Stress", width: 80)
                        TableHeaderCell(text: "Blood Pressure", width: 100)
                        TableHeaderCell(text: "Cortisol", width: 80)
        }
    }
    
    private func tableDataRow(data: BiometricData, index: Int) -> some View {
        HStack(spacing: 0) {
            TableDataCell(
                text: formatDate(data.date),
                width: 100,
                isEven: index % 2 == 0
            )
            TableDataCell(
                text: "\(Int(data.heartRate))",
                width: 80,
                isEven: index % 2 == 0,
                status: BiometricMetric.heartRate.normalRange?.status(for: data.heartRate)
            )
            TableDataCell(
                text: "\(Int(data.hrv))",
                width: 80,
                isEven: index % 2 == 0,
                status: BiometricMetric.hrv.normalRange?.status(for: data.hrv)
            )
            TableDataCell(
                text: "\(Int(data.sleepQuality))%",
                width: 80,
                isEven: index % 2 == 0,
                status: BiometricMetric.sleepQuality.normalRange?.status(for: data.sleepQuality)
            )
            TableDataCell(
                text: String(format: "%.1f", data.stressLevel),
                width: 80,
                isEven: index % 2 == 0,
                status: BiometricMetric.stressLevel.normalRange?.status(for: data.stressLevel)
            )
            TableDataCell(
                text: "\(Int(data.bloodPressureSystolic))/\(Int(data.bloodPressureDiastolic))",
                width: 100,
                isEven: index % 2 == 0
            )
            TableDataCell(
                text: String(format: "%.1f", data.cortisolLevel),
                width: 80,
                isEven: index % 2 == 0,
                status: BiometricMetric.cortisol.normalRange?.status(for: data.cortisolLevel)
            )
        }
    }
    
    private var medicalMetricsGridContent: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(BiometricMetric.allCases, id: \.self) { metric in
                let currentValue = getCurrentValue(for: metric)
                let trend = getTrend(for: metric)
                
                MedicalMetricCard(
                    metric: metric,
                    currentValue: currentValue,
                    trend: trend
                )
            }
        }
    }
    
    private var chartView: some View {
        Chart(filteredData, id: \.id) { data in
            let value = selectedMetric.getValue(from: data)
            
            LineMark(
                x: .value("日期", data.date),
                y: .value(selectedMetric.displayName, value)
            )
            .foregroundStyle(selectedMetric.color)
            .lineStyle(StrokeStyle(lineWidth: 2))
            
            AreaMark(
                x: .value("日期", data.date),
                y: .value(selectedMetric.displayName, value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [selectedMetric.color.opacity(0.3), selectedMetric.color.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    private var filteredData: [BiometricData] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch selectedTimeRange {
        case .week:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        }
        
        return biometricData.filter { $0.date >= startDate }
    }
    
    private func loadBiometricData() {
        // 生成模拟数据
        var data: [BiometricData] = []
        let calendar = Calendar.current
        let now = Date()
        
        for i in 0..<180 { // 6个月的数据
            let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
            
            data.append(BiometricData(
                date: date,
                heartRate: Double.random(in: 60...100) + sin(Double(i) * 0.1) * 10,
                hrv: Double.random(in: 20...60) + cos(Double(i) * 0.05) * 15,
                sleepQuality: Double.random(in: 50...95) + sin(Double(i) * 0.08) * 20,
                stressLevel: Double.random(in: 2...8) + cos(Double(i) * 0.12) * 2,
                bloodPressureSystolic: Double.random(in: 110...140),
                bloodPressureDiastolic: Double.random(in: 70...90),
                cortisolLevel: Double.random(in: 5...25) + sin(Double(i) * 0.15) * 8,
                recoveryScore: Double.random(in: 60...95)
            ))
        }
        
        biometricData = data.sorted { $0.date < $1.date }
    }
    
    private func getCurrentValue(for metric: BiometricMetric) -> Double {
        guard let latestData = biometricData.last else { return 0 }
        return metric.getValue(from: latestData)
    }
    
    private func getTrend(for metric: BiometricMetric) -> TrendDirection {
        guard biometricData.count >= 7 else { return .stable }
        
        let recent = Array(biometricData.suffix(7))
        let older = Array(biometricData.suffix(14).prefix(7))
        
        let recentAvg = recent.map { metric.getValue(from: $0) }.reduce(0, +) / Double(recent.count)
        let olderAvg = older.map { metric.getValue(from: $0) }.reduce(0, +) / Double(older.count)
        
        let change = (recentAvg - olderAvg) / olderAvg * 100
        
        if change > 5 {
            return .up
        } else if change < -5 {
            return .down
        } else {
            return .stable
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - 支持枚举和结构

enum BiometricMetric: String, CaseIterable {
    case heartRate = "Heart Rate"
    case hrv = "HRV"
    case sleepQuality = "Sleep Quality"
    case stressLevel = "Stress Level"
    case bloodPressure = "Blood Pressure"
    case cortisol = "Cortisol"
    
    var displayName: String { rawValue }
    
    var unit: String {
        switch self {
        case .heartRate: return "BPM"
        case .hrv: return "ms"
        case .sleepQuality: return "%"
        case .stressLevel: return "/10"
        case .bloodPressure: return "mmHg"
        case .cortisol: return "μg/dL"
        }
    }
    
    var color: Color {
        switch self {
        case .heartRate: return .red
        case .hrv: return .green
        case .sleepQuality: return .blue
        case .stressLevel: return .orange
        case .bloodPressure: return .purple
        case .cortisol: return .pink
        }
    }
    
    var icon: String {
        switch self {
        case .heartRate: return "heart.fill"
        case .hrv: return "waveform.path.ecg"
        case .sleepQuality: return "bed.double.fill"
        case .stressLevel: return "brain.head.profile"
        case .bloodPressure: return "drop.fill"
        case .cortisol: return "testtube.2"
        }
    }
    
    var normalRange: BiometricRange? {
        switch self {
        case .heartRate:
            return BiometricRange(min: 40, max: 120, optimal: 60...100)
        case .hrv:
            return BiometricRange(min: 10, max: 80, optimal: 30...60)
        case .sleepQuality:
            return BiometricRange(min: 0, max: 100, optimal: 70...100)
        case .stressLevel:
            return BiometricRange(min: 0, max: 10, optimal: 0...5)
        case .bloodPressure:
            return nil // 血压需要特殊处理
        case .cortisol:
            return BiometricRange(min: 0, max: 50, optimal: 5...20)
        }
    }
    
    func getValue(from data: BiometricData) -> Double {
        switch self {
        case .heartRate: return data.heartRate
        case .hrv: return data.hrv
        case .sleepQuality: return data.sleepQuality
        case .stressLevel: return data.stressLevel
        case .bloodPressure: return data.bloodPressureSystolic
        case .cortisol: return data.cortisolLevel
        }
    }
}

enum BiometricTimeRange: String, CaseIterable {
    case week = "1 Week"
    case month = "1 Month"
    case threeMonths = "3 Months"
    case sixMonths = "6 Months"
}

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

// MARK: - 支持组件

struct MetricButton: View {
    let metric: BiometricMetric
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: metric.icon)
                    .font(.caption)
                
                Text(metric.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : metric.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? metric.color : metric.color.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MedicalMetricCard: View {
    let metric: BiometricMetric
    let currentValue: Double
    let trend: TrendDirection
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: metric.icon)
                    .foregroundColor(metric.color)
                    .font(.title3)
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .foregroundColor(trend.color)
                    .font(.caption)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(metric.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(alignment: .bottom, spacing: 2) {
                    Text("\(currentValue, specifier: "%.1f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(metric.unit)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if let range = metric.normalRange {
                    let status = range.status(for: currentValue)
                    Text(status.description)
                        .font(.caption2)
                        .foregroundColor(status.color)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct RecoveryIndicator: View {
    let title: String
    let score: Int
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(score)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(score > 70 ? .green : .orange)
            }
            
            ProgressView(value: Double(score), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: score > 70 ? .green : .orange))
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }
}

struct TableHeaderCell: View {
    let text: String
    let width: CGFloat
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .frame(width: width, alignment: .center)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
    }
}

struct TableDataCell: View {
    let text: String
    let width: CGFloat
    let isEven: Bool
    var status: BiometricStatus? = nil
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(status?.color ?? .primary)
            .frame(width: width, alignment: .center)
            .padding(.vertical, 6)
            .background(isEven ? Color(.systemBackground) : Color(.secondarySystemBackground))
    }
}

// MARK: - 预览
struct BiometricDataView_Previews: PreviewProvider {
    static var previews: some View {
        BiometricDataView()
    }
}
