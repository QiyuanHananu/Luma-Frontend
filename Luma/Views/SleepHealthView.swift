//
//  SleepHealthView.swift
//  Luma
//

import SwiftUI
import Charts

struct SleepHealthView: View {
    @State private var isListening = false
    @State private var latestSleepHours: Double?
    @State private var latestUpdateTime: Date?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var weeklySleepTrend: [HealthKitManager.DailyTrendPoint] = []
    private let gutter: CGFloat = 10

    var body: some View {
        HStack {
            Text("Sleep Health")
                .font(.headline)
                .padding(.horizontal, gutter)
            Spacer()
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(Image(systemName: "person.fill").font(.caption))
                .padding(.horizontal, gutter)
        }
        .padding(.top, 8)
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TopBadgeIcon(symbol: "bed.double.fill", color: .purple)
                        .frame(maxWidth: .infinity)

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

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Sleep Duration (7 Nights)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }

                        if weeklySleepTrend.isEmpty {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                                .frame(height: 220)
                                .overlay(
                                    Text("No 7-night sleep trend yet.")
                                        .foregroundColor(.secondary)
                                )
                        } else {
                            Chart(weeklySleepTrend) { point in
                                LineMark(
                                    x: .value("Date", point.date),
                                    y: .value("Hours", point.value)
                                )
                                .foregroundStyle(.purple)
                                .interpolationMethod(.catmullRom)

                                PointMark(
                                    x: .value("Date", point.date),
                                    y: .value("Hours", point.value)
                                )
                                .foregroundStyle(.purple)
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) {
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                                }
                            }
                            .chartYScale(domain: .automatic(includesZero: false))
                            .frame(height: 220)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    if let latestUpdateTime {
                        Text("Last updated: \(latestUpdateTime.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }

                    Button {
                        fetchLatestSleep()
                        fetchSleepTrend()
                    } label: {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                            Text(isLoading ? "Refreshing..." : "Refresh Sleep")
                                .font(.subheadline.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .disabled(isLoading)
                    .buttonStyle(.borderedProminent)

                    Color.clear.frame(height: 120)
                }
                .padding(.horizontal, 16)
            }

            LongPressVoiceButton(isListening: $isListening,
                                 color: .purple,
                                 minDuration: 0.5,
                                 baseDiameter: 64,
                                 ringCount: 3) {
                print("🎙️ Long press recognized, start voice...")
            }
            .padding(.bottom, 22)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            fetchLatestSleep()
            fetchSleepTrend()
        }
    }

    private var sleepDisplayText: String {
        guard let latestSleepHours else { return "-- h" }
        return String(format: "%.1f h", latestSleepHours)
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
                    errorMessage = "No Apple Watch sleep sample found for last night."
                    return
                }

                latestSleepHours = hours
                latestUpdateTime = Date()

                Task {
                    await HealthMetricsService.shared.uploadSleep(
                        hours: hours,
                        sampledAt: Date()
                    )
                }
            }
        }
    }

    private func fetchSleepTrend() {
        HealthKitManager.shared.fetchSleepTrendLast7Nights { points in
            DispatchQueue.main.async {
                weeklySleepTrend = points
            }
        }
    }
}

#Preview {
    SleepHealthView()
}
