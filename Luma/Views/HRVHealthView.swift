//
//  HRVHealthView.swift
//  Luma
//


import SwiftUI
import Charts

struct HRVHealthView: View {
    @State private var isListening = false
    @State private var latestHRVMS: Double?
    @State private var latestUpdateTime: Date?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedRange: HRVChartRange = .day
    @State private var hrvChartData: [HRVChartPoint] = []
    private let gutter: CGFloat = 10

    private var isRunningInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        TopBadgeIcon(symbol: "waveform.path.ecg", color: .green)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)

                        summaryCards

                        hrvTrendSection

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.horizontal, 2)
                        }

                        Button {
                            fetchLatestHRV()
                        } label: {
                            HStack(spacing: 8) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                }
                                Text(isLoading ? "Refreshing..." : "Refresh from Apple Watch")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .disabled(isLoading)
                        .buttonStyle(.borderedProminent)
                        .tint(.green)

                        healthTipCard

                        Color.clear.frame(height: 120)
                    }
                    .padding(.horizontal, 16)
                }

                LongPressVoiceButton(
                    isListening: $isListening,
                    color: .green,
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
            if isRunningInPreview {
                loadPreviewData()
            } else {
                fetchLatestHRV()
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
                title: "HRV (SDNN)",
                value: hrvDisplayText,
                tint: .green
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Source")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Apple Watch")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.green)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
        }
    }

    private var healthTipCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Health Tip")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            Text(healthTipText)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
    }

    private var hrvDisplayText: String {
        guard let latestHRVMS else { return "-- ms" }
        return String(format: "%.0f ms", latestHRVMS)
    }

    private var healthTipText: String {
        guard let latestHRVMS else {
            return "Wear your Apple Watch consistently to generate HRV recovery insights."
        }

        if latestHRVMS < 20 {
            return "Your HRV looks quite low. Try to keep today gentle and prioritize rest."
        }

        if latestHRVMS < 35 {
            return "Your HRV is a bit low. Hydration, light movement, and steady sleep may help recovery."
        }

        return "Your HRV looks stable. Keep your recovery routine consistent."
    }

    private var hrvTrendSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("HRV Trend")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("View your HRV records by day, week, or month.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Picker("HRV range", selection: $selectedRange) {
                ForEach(HRVChartRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedRange) { _, _ in
                fetchHRVChartData()
            }

            VStack(spacing: 8) {
                if hrvChartData.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.title2)
                            .foregroundColor(.secondary.opacity(0.7))

                        Text("No HRV trend data available yet.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Chart(hrvChartData) { point in
                        LineMark(
                            x: .value("Time", point.date),
                            y: .value("HRV", point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.green)
                    }
                    .chartYAxisLabel("ms")
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: selectedRange == .day ? 4 : 6))
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .padding(12)
                }

                if let latestUpdateTime {
                    Text("Last updated: \(latestUpdateTime.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 0.5))
        }
    }

    private func loadPreviewData() {
        latestHRVMS = 42
        latestUpdateTime = Date()
        errorMessage = nil
        isLoading = false

        let now = Date()
        hrvChartData = [
            HRVChartPoint(date: now.addingTimeInterval(-60 * 60 * 6), value: 34),
            HRVChartPoint(date: now.addingTimeInterval(-60 * 60 * 5), value: 38),
            HRVChartPoint(date: now.addingTimeInterval(-60 * 60 * 4), value: 36),
            HRVChartPoint(date: now.addingTimeInterval(-60 * 60 * 3), value: 44),
            HRVChartPoint(date: now.addingTimeInterval(-60 * 60 * 2), value: 41),
            HRVChartPoint(date: now.addingTimeInterval(-60 * 60), value: 42)
        ]
    }

    private func fetchHRVChartData() {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date

        switch selectedRange {
        case .day:
            startDate = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }

        HealthKitManager.shared.fetchHRVReadings(from: startDate, to: now) { readings in
            DispatchQueue.main.async {
                hrvChartData = readings.map { reading in
                    HRVChartPoint(date: reading.startDate, value: reading.sdnnMs)
                }

                if hrvChartData.isEmpty {
                    errorMessage = "No Apple Watch HRV trend samples found for this range."
                } else if errorMessage?.hasPrefix("No Apple Watch HRV") == true {
                    errorMessage = nil
                }
            }
        }
    }

    private func fetchLatestHRV() {
        isLoading = true
        errorMessage = nil

        HealthKitManager.shared.fetchAverageHRVLast24Hours { value in
            DispatchQueue.main.async {
                isLoading = false

                guard let value else {
                    latestHRVMS = nil
                    latestUpdateTime = nil
                    errorMessage = "No Apple Watch HRV sample found in last 24h."
                    fetchHRVChartData()
                    return
                }

                latestHRVMS = value
                latestUpdateTime = Date()
                fetchHRVChartData()

                Task {
                    await HealthMetricsService.shared.uploadHRV(
                        sdnnMs: value,
                        sampledAt: Date()
                    )
                }
            }
        }
    }
}



private enum HRVChartRange: String, CaseIterable, Identifiable {
    case day
    case week
    case month

    var id: String { rawValue }

    var title: String {
        switch self {
        case .day:
            return "Day"
        case .week:
            return "Week"
        case .month:
            return "Month"
        }
    }
}

private struct HRVChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

#Preview {
    HRVHealthView()
}
