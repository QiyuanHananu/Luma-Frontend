//
//  CopingSkillsView.swift
//  Luma - AI健康伴侣应用
//
//  功能说明：
//  - 应对技能和自助工具页面
//  - 提供冥想、呼吸练习、放松技巧等功能
//  - 情绪管理工具和技巧库
//  - 个性化的应对建议和指导
//  - 可选的语音引导和日记功能
//
//  主要功能：
//  1. 呼吸练习 - 引导式深呼吸和放松练习
//  2. 冥想库 - 各种类型的冥想音频和指导
//  3. 情绪日记 - 私人情感记录和反思空间
//  4. 放松技巧 - 快速缓解压力的方法
//  5. 个性化建议 - 基于用户状态的推荐技能
//
//  Created by Han on 23/8/2025.
//

import SwiftUI

struct CopingSkillsView: View {
    // MARK: - 状态管理
    @State private var selectedCategory: SkillCategory = .all
    @State private var showingBreathingExercise = false
    @State private var showingJournal = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 快速救急工具
                    quickToolsSection
                    
                    // 技能分类选择器
                    categorySelector
                    
                    // 技能列表
                    skillsGridSection
                    
                    // 个性化推荐
                    recommendedSection
                }
                .padding()
            }
            .navigationTitle("应对技能")
        }
        .sheet(isPresented: $showingBreathingExercise) {
            BreathingExerciseView()
        }
        .sheet(isPresented: $showingJournal) {
            JournalView()
        }
    }
    
    // MARK: - 快速工具
    private var quickToolsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("快速救急")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickToolCard(
                    icon: "wind",
                    title: "深呼吸",
                    subtitle: "3分钟放松",
                    color: .blue
                ) {
                    showingBreathingExercise = true
                }
                
                QuickToolCard(
                    icon: "book.pages",
                    title: "情绪日记",
                    subtitle: "记录感受",
                    color: .purple
                ) {
                    showingJournal = true
                }
                
                QuickToolCard(
                    icon: "phone.fill",
                    title: "紧急求助",
                    subtitle: "立即获得帮助",
                    color: .red
                ) {
                    // 紧急求助功能
                }
                
                QuickToolCard(
                    icon: "music.note",
                    title: "放松音乐",
                    subtitle: "舒缓心情",
                    color: .green
                ) {
                    // 播放放松音乐
                }
            }
        }
    }
    
    // MARK: - 分类选择器
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SkillCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - 技能网格
    private var skillsGridSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(selectedCategory.displayName)
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                ForEach(filteredSkills, id: \.id) { skill in
                    SkillCard(skill: skill) {
                        // 打开技能详情
                    }
                }
            }
        }
    }
    
    // MARK: - 推荐部分
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("为您推荐")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("基于您的最近状态")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(recommendedSkills, id: \.id) { skill in
                        RecommendedSkillCard(skill: skill) {
                            // 打开推荐技能
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - 计算属性
    private var filteredSkills: [CopingSkill] {
        if selectedCategory == .all {
            return CopingSkill.mockData
        } else {
            return CopingSkill.mockData // UI版本：显示所有技能
        }
    }
    
    private var recommendedSkills: [CopingSkill] {
        // 基于用户状态推荐技能
        return CopingSkill.mockData.prefix(3).map { $0 }
    }
}

// MARK: - 子视图组件

struct QuickToolCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryButton: View {
    let category: SkillCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.displayName)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct SkillCard: View {
    let skill: CopingSkill
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: skill.icon)
                        .font(.title2)
                        .foregroundColor(skill.color)
                    
                    Spacer()
                    
                    Text("\(skill.duration)分钟")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(skill.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                    
                    Text(skill.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding()
            .frame(height: 120)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecommendedSkillCard: View {
    let skill: CopingSkill
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: skill.icon)
                    .font(.title2)
                    .foregroundColor(skill.color)
                
                Text(skill.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(skill.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .padding()
            .frame(width: 150, height: 120)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 数据模型

enum SkillCategory: String, CaseIterable {
    case all = "all"
    case breathing = "breathing"
    case meditation = "meditation"
    case journaling = "journaling"
    case relaxation = "relaxation"
    case mindfulness = "mindfulness"
    
    var displayName: String {
        switch self {
        case .all: return "全部"
        case .breathing: return "呼吸练习"
        case .meditation: return "冥想"
        case .journaling: return "日记"
        case .relaxation: return "放松"
        case .mindfulness: return "正念"
        }
    }
}

enum SkillDifficulty: String, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    
    var displayName: String {
        switch self {
        case .beginner: return "初级"
        case .intermediate: return "中级"
        case .advanced: return "高级"
        }
    }
}



// MARK: - 预览
#Preview {
    CopingSkillsView()
}
