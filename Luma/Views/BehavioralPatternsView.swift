//
//  BehavioralPatternsView.swift
//  Luma
//
// 
//

import SwiftUI
import Charts

// MARK: - 行为模式数据模型
struct BehavioralPattern {
    let id = UUID()
    let title: String
    let description: String
    let correlation: Double // 相关性强度 (0-1)
    let frequency: Int // 出现频率
    let category: PatternCategory
    let significance: PatternSignificance
    let triggerFactors: [String]
    let interventionSuggestions: [String]
}

struct InterventionEffectiveness {
    let id = UUID()
    let name: String
    let successRate: Double
    let usageCount: Int
    let averageImprovement: Double
    let category: InterventionCategory
}

enum PatternCategory: String, CaseIterable {
    case emotional = "Emotional Patterns"
    case behavioral = "Behavioral Patterns"
    case physiological = "Physiological Patterns"
    case environmental = "Environmental Patterns"
    
    var color: Color {
        switch self {
        case .emotional: return .purple
        case .behavioral: return .blue
        case .physiological: return .red
        case .environmental: return .green
        }
    }
    
    var icon: String {
        switch self {
        case .emotional: return "heart.fill"
        case .behavioral: return "person.fill"
        case .physiological: return "waveform.path.ecg"
        case .environmental: return "leaf.fill"
        }
    }
}

enum PatternSignificance: String, CaseIterable {
    case critical = "Critical"
    case important = "Important"
    case moderate = "Moderate"
    case minor = "Minor"
    
    var color: Color {
        switch self {
        case .critical: return .red
        case .important: return .orange
        case .moderate: return .yellow
        case .minor: return .green
        }
    }
}

enum InterventionCategory: String, CaseIterable {
    case breathing = "Breathing Exercises"
    case meditation = "Meditation"
    case exercise = "Exercise"
    case sleep = "Sleep Regulation"
    case cognitive = "Cognitive Regulation"
    case social = "Social Support"
    
    var color: Color {
        switch self {
        case .breathing: return .blue
        case .meditation: return .purple
        case .exercise: return .green
        case .sleep: return .indigo
        case .cognitive: return .orange
        case .social: return .pink
        }
    }
    
    var icon: String {
        switch self {
        case .breathing: return "wind"
        case .meditation: return "brain.head.profile"
        case .exercise: return "figure.run"
        case .sleep: return "bed.double.fill"
        case .cognitive: return "lightbulb.fill"
        case .social: return "person.2.fill"
        }
    }
}

// MARK: - 行为模式分析视图
struct BehavioralPatternsView: View {
    @State private var selectedCategory: PatternCategory? = nil
    @State private var behavioralPatterns: [BehavioralPattern] = []
    @State private var interventionData: [InterventionEffectiveness] = []
    @State private var showPatternDetail = false
    @State private var selectedPattern: BehavioralPattern?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // AI发现的相关性
                aiCorrelationsCard
                
                // 行为模式分类
                patternCategoriesCard
                
                // 干预有效性分析
                interventionEffectivenessCard
                
                // 触发因素识别
                triggerFactorsCard
                
                // 模式详细列表
                patternDetailsList
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .onAppear {
            loadBehavioralData()
        }
        .sheet(isPresented: $showPatternDetail) {
            if let pattern = selectedPattern {
                PatternDetailView(pattern: pattern)
            }
        }
    }
    
    private var aiCorrelationsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text("Significant Patterns Discovered by AI")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("12 Patterns")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                CorrelationItem(
                    title: "Monday Mood Decline",
                    correlation: 1.0,
                    description: "Significant mood decline every Monday, highly correlated with work stress"
                )
                
                CorrelationItem(
                    title: "Sleep Deprivation & Stress",
                    correlation: 0.89,
                    description: "When sleep duration is less than 6 hours, next-day stress levels increase by 89%"
                )
                
                CorrelationItem(
                    title: "Post-Exercise Mood Improvement",
                    correlation: 0.76,
                    description: "Within 2 hours after exercise, mood scores improve by an average of 76%"
                )
                
                CorrelationItem(
                    title: "Social Activities & Recovery",
                    correlation: 0.68,
                    description: "After participating in social activities, stress recovery speed improves by 68%"
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var patternCategoriesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pattern Classification Analysis")
                .font(.headline)
                .fontWeight(.semibold)
            
            // 分类选择器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                        PatternCategoryButton(
                            category: nil,
                            title: "All",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }
                    
                    ForEach(PatternCategory.allCases, id: \.self) { category in
                        PatternCategoryButton(
                            category: category,
                            title: category.rawValue,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // 热力图显示模式频率
            PatternHeatmapView(patterns: filteredPatterns)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var interventionEffectivenessCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Intervention Effectiveness")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(interventionData, id: \.id) { intervention in
                    InterventionCard(intervention: intervention)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var triggerFactorsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("触发因素识别")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                TriggerFactorCard(
                    title: "Time Factors",
                    factors: ["Monday Morning", "Late Night Hours", "After Lunch", "Weekend End"],
                    color: .blue
                )
                
                TriggerFactorCard(
                    title: "Environmental Factors",
                    factors: ["Workplace", "Noisy Environment", "Enclosed Spaces", "Crowded Areas"],
                    color: .green
                )
                
                TriggerFactorCard(
                    title: "Physiological Factors",
                    factors: ["Sleep Deprivation", "Hunger State", "Fatigue Accumulation", "Hormonal Changes"],
                    color: .red
                )
                
                TriggerFactorCard(
                    title: "Psychological Factors",
                    factors: ["Work Stress", "Interpersonal Conflict", "Decision Difficulty", "Perfectionism"],
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var patternDetailsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("详细模式列表")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(filteredPatterns, id: \.id) { pattern in
                    PatternListItem(pattern: pattern) {
                        selectedPattern = pattern
                        showPatternDetail = true
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var filteredPatterns: [BehavioralPattern] {
        if let category = selectedCategory {
            return behavioralPatterns.filter { $0.category == category }
        }
        return behavioralPatterns
    }
    
    private func loadBehavioralData() {
        // 加载行为模式数据
        behavioralPatterns = [
            BehavioralPattern(
                title: "周一情绪低落模式",
                description: "每周一情绪指标显著下降，持续时间2-4小时",
                correlation: 1.0,
                frequency: 48,
                category: .emotional,
                significance: .critical,
                triggerFactors: ["工作日开始", "周末结束", "任务压力"],
                interventionSuggestions: ["周日晚准备", "周一早晨冥想", "渐进式任务安排"]
            ),
            BehavioralPattern(
                title: "睡眠不足压力循环",
                description: "睡眠不足导致压力增加，压力又影响睡眠质量",
                correlation: 0.89,
                frequency: 32,
                category: .physiological,
                significance: .critical,
                triggerFactors: ["工作加班", "电子设备使用", "咖啡因摄入"],
                interventionSuggestions: ["睡前数字排毒", "固定作息时间", "放松技巧"]
            ),
            BehavioralPattern(
                title: "社交回避行为",
                description: "压力高时倾向于回避社交活动，进一步加重孤独感",
                correlation: 0.72,
                frequency: 28,
                category: .behavioral,
                significance: .important,
                triggerFactors: ["高压力期", "情绪低落", "自我怀疑"],
                interventionSuggestions: ["渐进式社交", "支持网络激活", "自我关怀练习"]
            ),
            BehavioralPattern(
                title: "完美主义拖延",
                description: "对完美的追求导致任务拖延，增加焦虑水平",
                correlation: 0.65,
                frequency: 24,
                category: .behavioral,
                significance: .important,
                triggerFactors: ["重要任务", "他人期望", "自我批评"],
                interventionSuggestions: ["分解任务", "接受不完美", "时间管理技巧"]
            )
        ]
        
        // 加载干预效果数据
        interventionData = [
            InterventionEffectiveness(
                name: "深呼吸练习",
                successRate: 0.92,
                usageCount: 156,
                averageImprovement: 34.5,
                category: .breathing
            ),
            InterventionEffectiveness(
                name: "正念冥想",
                successRate: 0.87,
                usageCount: 89,
                averageImprovement: 28.3,
                category: .meditation
            ),
            InterventionEffectiveness(
                name: "有氧运动",
                successRate: 0.81,
                usageCount: 67,
                averageImprovement: 42.1,
                category: .exercise
            ),
            InterventionEffectiveness(
                name: "睡眠优化",
                successRate: 0.76,
                usageCount: 45,
                averageImprovement: 38.7,
                category: .sleep
            )
        ]
    }
}

// MARK: - 支持组件

struct CorrelationItem: View {
    let title: String
    let correlation: Double
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
            
            VStack(spacing: 4) {
                Text("\(Int(correlation * 100))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(correlationColor(correlation))
                
                ProgressView(value: correlation, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: correlationColor(correlation)))
                    .frame(width: 60)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func correlationColor(_ value: Double) -> Color {
        if value > 0.8 { return .red }
        else if value > 0.6 { return .orange }
        else if value > 0.4 { return .yellow }
        else { return .green }
    }
}

struct PatternCategoryButton: View {
    let category: PatternCategory?
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let category = category {
                    Image(systemName: category.icon)
                        .font(.caption)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : (category?.color ?? .blue))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? (category?.color ?? .blue) : (category?.color.opacity(0.1) ?? Color.blue.opacity(0.1)))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PatternHeatmapView: View {
    let patterns: [BehavioralPattern]
    
    var body: some View {
        VStack(spacing: 8) {
            Text("模式出现频率热力图")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(0..<28, id: \.self) { day in
                    let intensity = getIntensity(for: day)
                    Rectangle()
                        .fill(intensityColor(intensity))
                        .frame(height: 20)
                        .cornerRadius(4)
                }
            }
            
            HStack {
                Text("低频")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("高频")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func getIntensity(for day: Int) -> Double {
        // 模拟数据：基于模式生成热力图强度
        let baseIntensity = Double.random(in: 0...1)
        let weekdayMultiplier = (day % 7 < 5) ? 1.2 : 0.8 // 工作日更高
        return min(baseIntensity * weekdayMultiplier, 1.0)
    }
    
    private func intensityColor(_ intensity: Double) -> Color {
        if intensity > 0.8 { return .red }
        else if intensity > 0.6 { return .orange }
        else if intensity > 0.4 { return .yellow }
        else if intensity > 0.2 { return .green.opacity(0.6) }
        else { return .gray.opacity(0.3) }
    }
}

struct InterventionCard: View {
    let intervention: InterventionEffectiveness
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: intervention.category.icon)
                .foregroundColor(intervention.category.color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(intervention.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("使用\(intervention.usageCount)次 · 平均改善\(intervention.averageImprovement, specifier: "%.1f")%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(intervention.successRate * 100))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(intervention.category.color)
                
                Text("有效率")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct TriggerFactorCard: View {
    let title: String
    let factors: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            VStack(spacing: 6) {
                ForEach(factors, id: \.self) { factor in
                    HStack {
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                        
                        Text(factor)
                            .font(.caption)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct PatternListItem: View {
    let pattern: BehavioralPattern
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(pattern.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("相关性 \(Int(pattern.correlation * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(pattern.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(pattern.category.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(pattern.category.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(pattern.category.color.opacity(0.1))
                            .cornerRadius(6)
                        
                        Text(pattern.significance.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(pattern.significance.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(pattern.significance.color.opacity(0.1))
                            .cornerRadius(6)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 模式详情视图
struct PatternDetailView: View {
    let pattern: BehavioralPattern
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 模式基本信息
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: pattern.category.icon)
                                .foregroundColor(pattern.category.color)
                                .font(.title2)
                            
                            Text(pattern.category.rawValue)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(pattern.category.color)
                            
                            Spacer()
                            
                            Text("相关性 \(Int(pattern.correlation * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(pattern.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(pattern.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // 触发因素
                    VStack(alignment: .leading, spacing: 12) {
                        Text("触发因素")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            ForEach(pattern.triggerFactors, id: \.self) { factor in
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    
                                    Text(factor)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // 干预建议
                    VStack(alignment: .leading, spacing: 12) {
                        Text("干预建议")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            ForEach(pattern.interventionSuggestions, id: \.self) { suggestion in
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                    
                                    Text(suggestion)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("模式详情")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("关闭") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - 预览
struct BehavioralPatternsView_Previews: PreviewProvider {
    static var previews: some View {
        BehavioralPatternsView()
    }
}
