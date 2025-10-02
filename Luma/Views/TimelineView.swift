//
//  TimelineView.swift
//  Luma
//
//  
//

import SwiftUI

// MARK: - 详细时间线视图
struct TimelineView: View {
    @State private var selectedFilter: EventFilter = .all
    @State private var timelineEvents: [TimelineEvent] = []
    @State private var showEventDetail = false
    @State private var selectedEvent: TimelineEvent?
    
    var body: some View {
        VStack(spacing: 0) {
            // 筛选器
            filterSection
            
            // 时间线内容
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredEvents, id: \.id) { event in
                        TimelineEventCard(event: event) {
                            selectedEvent = event
                            showEventDetail = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .onAppear {
            loadTimelineEvents()
        }
        .sheet(isPresented: $showEventDetail) {
            if let event = selectedEvent {
                EventDetailView(event: event)
            }
        }
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Event Filter")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(filteredEvents.count) Events")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(EventFilter.allCases, id: \.self) { filter in
                        FilterButton(
                            filter: filter,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private var filteredEvents: [TimelineEvent] {
        switch selectedFilter {
        case .all:
            return timelineEvents
        case .crisis:
            return timelineEvents.filter { $0.severity == .crisis }
        case .warning:
            return timelineEvents.filter { $0.severity == .warning }
        case .success:
            return timelineEvents.filter { $0.severity == .success }
        case .patterns:
            return timelineEvents.filter { $0.category == .pattern }
        }
    }
    
    private func loadTimelineEvents() {
        // 模拟时间线数据
        timelineEvents = [
            TimelineEvent(
                date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                title: "Abnormal Stress Level Increase",
                description: "Detected decreased heart rate variability, stress indicators exceeded threshold",
                severity: .crisis,
                category: .crisis
            ),
            TimelineEvent(
                date: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(),
                title: "Breathing Exercise Completed",
                description: "User completed 10-minute deep breathing exercise, stress level somewhat relieved",
                severity: .success,
                category: .intervention
            ),
            TimelineEvent(
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                title: "Abnormal Sleep Pattern",
                description: "AI detected sleep quality decline for 3 consecutive days, recommend adjusting sleep schedule",
                severity: .warning,
                category: .pattern
            ),
            TimelineEvent(
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                title: "Mood Journal Entry",
                description: "User actively recorded emotional state, showing mild anxiety",
                severity: .normal,
                category: .intervention
            ),
            TimelineEvent(
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                title: "Exercise Goal Achieved",
                description: "Completed daily step goal, heart rate returned to normal range",
                severity: .success,
                category: .recovery
            ),
            TimelineEvent(
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                title: "Work Stress Pattern Identified",
                description: "AI discovered regular pattern of 100% mood decline on Mondays",
                severity: .warning,
                category: .pattern
            )
        ]
    }
}

// MARK: - 事件筛选器枚举
enum EventFilter: String, CaseIterable {
    case all = "All Events"
    case crisis = "Crisis Events"
    case warning = "Warning Events"
    case success = "Success Events"
    case patterns = "Pattern Discovery"
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .crisis: return "exclamationmark.triangle.fill"
        case .warning: return "exclamationmark.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .patterns: return "brain.head.profile"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .blue
        case .crisis: return .red
        case .warning: return .orange
        case .success: return .green
        case .patterns: return .purple
        }
    }
}

// MARK: - 筛选按钮组件
struct FilterButton: View {
    let filter: EventFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                
                Text(filter.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : filter.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? filter.color : filter.color.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 时间线事件卡片
struct TimelineEventCard: View {
    let event: TimelineEvent
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 时间线指示器
                VStack {
                    Circle()
                        .fill(event.severity.color)
                        .frame(width: 12, height: 12)
                    
                    Rectangle()
                        .fill(event.severity.color.opacity(0.3))
                        .frame(width: 2, height: 40)
                }
                
                // 事件内容
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(event.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(formatEventTime(event.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(event.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        EventTag(text: event.severity.rawValue, color: event.severity.color)
                        EventTag(text: event.category.rawValue, color: .blue)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatEventTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - 事件标签组件
struct EventTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .cornerRadius(6)
    }
}

// MARK: - 事件详情视图
struct EventDetailView: View {
    let event: TimelineEvent
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 事件头部信息
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Circle()
                                .fill(event.severity.color)
                                .frame(width: 16, height: 16)
                            
                            Text(event.severity.rawValue)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(event.severity.color)
                            
                            Spacer()
                            
                            Text(formatFullDate(event.date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(event.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(event.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // 详细信息
                    VStack(alignment: .leading, spacing: 16) {
                        DetailSection(title: "Event Category", content: event.category.rawValue)
                        DetailSection(title: "Severity Level", content: event.severity.rawValue)
                        DetailSection(title: "Trigger Time", content: formatFullDate(event.date))
                        
                        if event.severity == .crisis {
                            DetailSection(
                                title: "Recommended Actions",
                                content: "Immediately perform deep breathing exercises. If symptoms persist, please contact medical professionals"
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// MARK: - 详情部分组件
struct DetailSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
        }
    }
}

// MARK: - 预览
struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
