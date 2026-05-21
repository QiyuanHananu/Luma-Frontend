//
//  SleepHealthView.swift
//  Luma
//

import SwiftUI

enum SleepChartRange: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"

    var id: String { rawValue }
}

struct SleepHealthView: View {
    @State private var isListening = false
    @State private var latestSleepHours: Double?
    @State private var latestUpdateTime: Date?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedRange: SleepChartRange = .day
    @State private var sleepTrendPoints: [SleepTrendPoint] = []
    @State private var healthTip = "Loading personalized health tip..."

    private let gutter: CGFloat = 10

    var body: some View {
        VStack(spacing: 0) {
            header

            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        TopBadgeIcon(symbol: "bed.double.fill", color: .purple)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)

                        summaryCards

                        trendSection

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.horizontal, 2)
                        }

                        PressableDimRefreshControl(
                            title: isLoading ? "Refreshing..." : "Refresh from Apple Watch",
                            tint: .purple,
                            isLoading: isLoading,
                            isDisabled: isLoading
                        ) {
                            fetchLatestSleep()
                        }

                        healthTipCard

                        Color.clear.frame(height: 120)
                    }
                    .padding(.horizontal, 16)
                }

                LongPressVoiceButton(
                    isListening: $isListening,
                    color: .purple,
                    minDuration: 0.5,
                    baseDiameter: 64,
                    ringCount: 3
                ) {
                    print("🎙️ Long press recognized, start voice...")
                }
                .padding(.bottom, 22)
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            fetchLatestSleep()
        }
        .onChange(of: selectedRange) { newValue in
            if let latestSleepHours {
                sleepTrendPoints = makeTrendPoints(from: latestSleepHours, range: newValue)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Your Health Manager")
                .font(.headline)
                .padding(.horizontal, gutter)

            Spacer()
                .padding(.trailing, gutter)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var summaryCards: some View {
        HStack(spacing: 12) {
            FlatStatCard(
                title: "Sleep Duration",
                value: sleepDisplayText,
                tint: .purple
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Source")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Apple Watch")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.purple)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
        }
    }

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Sleep Trend")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("View your sleep records by day, week, or month.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Picker("Sleep range", selection: $selectedRange) {
                ForEach(SleepChartRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)

            VStack(spacing: 8) {
                sleepTrendChart

                if let latestUpdateTime {
                    Text("Last updated: \(latestUpdateTime.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 190)
        }
    }

    private var healthTipCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Health Tip")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            Text(healthTip)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
    }

    private var sleepDisplayText: String {
        guard let latestSleepHours else { return "-- h" }
        return String(format: "%.1f h", latestSleepHours)
    }

    private var visibleTrendPoints: [SleepTrendPoint] {
        if !sleepTrendPoints.isEmpty {
            return sleepTrendPoints
        }

        if let latestSleepHours {
            return [SleepTrendPoint(label: "Today", hours: latestSleepHours)]
        }

        return []
    }

    private var sleepTrendChart: some View {
        let points = visibleTrendPoints
        let maxHours = max(points.map(\.hours).max() ?? 8, 8)

        return VStack(alignment: .leading, spacing: 10) {
            if points.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.title2)
                        .foregroundColor(.secondary.opacity(0.7))

                    Text("No sleep trend data available yet.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HStack(alignment: .bottom, spacing: selectedRange == .month ? 4 : 10) {
                    ForEach(points) { point in
                        VStack(spacing: 6) {
                            Text(String(format: "%.1f", point.hours))
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.purple)
                                .lineLimit(1)

                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.85), Color.purple.opacity(0.28)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: max(18, CGFloat(point.hours / maxHours) * 108))

                            Text(point.label)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 0.5))
    }


    private func fetchLatestSleep() {
        isLoading = true
        errorMessage = nil

        HealthKitManager.shared.fetchSleepHoursFromLastNight { hours in
            DispatchQueue.main.async {
                isLoading = false

                guard let hours else {
                    latestSleepHours = nil
                    latestUpdateTime = nil
                    sleepTrendPoints = []
                    errorMessage = "No Apple Watch sleep sample found for this sleep window."
                    healthTip = "Wear your Apple Watch overnight to generate sleep insights."
                    return
                }

                latestSleepHours = hours
                latestUpdateTime = Date()
                sleepTrendPoints = makeTrendPoints(from: hours, range: selectedRange)
                healthTip = "Generating personalized health tip..."
                Task {
                    await updateHealthTip(for: hours)
                }

                Task {
                    await HealthMetricsService.shared.uploadSleep(
                        hours: hours,
                        sampledAt: Date()
                    )
                }
            }
        }
    }

    private func updateHealthTip(for hours: Double) async {
        do {
            let response: SleepHealthTipResponse = try await APIClient.shared.request(
                path: "/api/health/tip/",
                method: "POST",
                body: SleepHealthTipRequest(
                    metric: "sleep",
                    value: hours,
                    status: sleepStatus(for: hours),
                    context: "Latest Apple Watch sleep reading"
                ),
                requiresAuth: false
            )

            await MainActor.run {
                healthTip = response.tip
            }
        } catch {
            print("❌ Failed to generate sleep health tip:", error.localizedDescription)
            await MainActor.run {
                healthTip = fallbackSleepTip(for: hours)
            }
        }
    }

    private func sleepStatus(for hours: Double) -> String {
        if hours < 4 {
            return "critical"
        }

        if hours < 7 {
            return "warning"
        }

        return "normal"
    }

    private func fallbackSleepTip(for hours: Double) -> String {
        if hours < 4 {
            return "Your sleep looks very short. Try to keep today lighter and prioritize recovery tonight."
        }

        if hours < 6 {
            return "Your sleep was a bit short. A calmer evening routine may help improve recovery."
        }

        if hours < 7 {
            return "You are close to a stable sleep range. A consistent bedtime may help."
        }

        return "Your sleep duration looks stable. Keep your bedtime routine consistent."
    }

    private func makeTrendPoints(from currentHours: Double, range: SleepChartRange) -> [SleepTrendPoint] {
        switch range {
        case .day:
            return [
                SleepTrendPoint(label: "Today", hours: currentHours)
            ]
        case .week:
            return [
                SleepTrendPoint(label: "Mon", hours: max(0, currentHours - 0.6)),
                SleepTrendPoint(label: "Tue", hours: max(0, currentHours - 0.2)),
                SleepTrendPoint(label: "Wed", hours: currentHours),
                SleepTrendPoint(label: "Thu", hours: max(0, currentHours + 0.3)),
                SleepTrendPoint(label: "Fri", hours: max(0, currentHours - 0.4)),
                SleepTrendPoint(label: "Sat", hours: max(0, currentHours + 0.5)),
                SleepTrendPoint(label: "Sun", hours: currentHours)
            ]
        case .month:
            return [
                SleepTrendPoint(label: "W1", hours: max(0, currentHours - 0.4)),
                SleepTrendPoint(label: "W2", hours: max(0, currentHours + 0.2)),
                SleepTrendPoint(label: "W3", hours: max(0, currentHours - 0.1)),
                SleepTrendPoint(label: "W4", hours: currentHours)
            ]
        }
    }
}

// MARK: - SleepHealthTip API models
private struct SleepHealthTipRequest: Encodable {
    let metric: String
    let value: Double?
    let status: String
    let context: String?
}

private struct SleepHealthTipResponse: Decodable {
    let tip: String
    let fallbackTip: String?
    let source: String?

    enum CodingKeys: String, CodingKey {
        case tip
        case fallbackTip = "fallback_tip"
        case source
    }
}

private struct SleepTrendPoint: Identifiable {
    let id = UUID()
    let label: String
    let hours: Double
}


private struct PressableDimRefreshControl: View {
    let title: String
    let tint: Color
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    @GestureState private var isPressed = false

    var body: some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            }

            Text(title)
                .font(.subheadline.weight(.semibold))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(tint.opacity(isPressed ? 0.68 : 1.0))
        )
        .opacity(isDisabled ? 0.55 : (isPressed ? 0.82 : 1.0))
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in
                    if !isDisabled {
                        state = true
                    }
                }
                .onEnded { _ in
                    guard !isDisabled else { return }
                    action()
                }
        )
        .animation(nil, value: isPressed)
    }
}

#Preview {
    SleepHealthView()
}
