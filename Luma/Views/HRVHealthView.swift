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

    var body: some View {
        HStack {
            Text("HRV Health")
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
                    TopBadgeIcon(symbol: "waveform.path.ecg", color: .green)
                        .frame(maxWidth: .infinity)

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

                    hrvTrendSection

                    Button {
                        fetchLatestHRV()
                    } label: {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                            Text(isLoading ? "Refreshing..." : "Refresh HRV")
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
                                 color: .green,
                                 minDuration: 0.5,
                                 baseDiameter: 64,
                                 ringCount: 3) {
                print("🎙️ Long press recognized, start voice...")
            }
            .padding(.bottom, 22)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            fetchLatestHRV()
        }
    }

    private var hrvDisplayText: String {
        guard let latestHRVMS else { return "-- ms" }
        return String(format: "%.0f ms", latestHRVMS)
    }

    private var hrvTrendSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("HRV Trend")
                        .font(.headline)
                    Text("View your HRV records by day, week, or month.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Picker("Range", selection: $selectedRange) {
                ForEach(HRVChartRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedRange) { _, _ in
                fetchHRVChartData()
            }

            if hrvChartData.isEmpty {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(height: 220)
                    .overlay(
                        Text("No HRV trend data available yet.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    )
            } else {
                Chart(hrvChartData) { point in
                    LineMark(
                        x: .value("Time", point.date),
                        y: .value("HRV", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.green)

                    PointMark(
                        x: .value("Time", point.date),
                        y: .value("HRV", point.value)
                    )
                    .foregroundStyle(Color.green)
                }
                .chartYAxisLabel("ms")
                .frame(height: 220)
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
            }
        }
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
