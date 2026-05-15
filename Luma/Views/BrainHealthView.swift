//
//  BrainHealthView.swift
//  Luma
//
//  Created by Jiaoyang Liu on 11/9/2025.
//


import SwiftUI
import Charts
import HealthKit

// MARK: - Brain Health (blue & white theme)
struct BrainHealthView: View {
    @State private var isListening = false
    @State private var trendSelection = "Sleep Quality"
    @State private var healthTip = "Your sleep duration improved this week. Keep the habit!"
    @State private var selectedRange: BrainChartRange = .day
    @State private var brainChartData: [BrainChartPoint] = []
    @State private var chartErrorMessage: String?
    private let gutter: CGFloat = 10
    private let healthStore = HKHealthStore()
    
    var body: some View {
            
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 20) {

                // Top bar
                HStack {
                    Text("Your Health Manager")
                        .font(.headline)
                        .padding(.horizontal, gutter)
                    Spacer()
                    Button {
                        print("🔔 Notification tapped")
                    } label: {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    .padding(.trailing, 8)

                    // Avatar placeholder
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(Image(systemName: "person.fill").font(.caption))
                }
                .padding(.top, 8)
                .padding(.horizontal, gutter)

            // Scrollable content
            ScrollView {

                    // Summary cards
                    HStack(spacing: 12) {
                        FlatStatCard(title: "Sleep Quality", value: "85%", tint: .blue)
                            .onTapGesture {
                                trendSelection = "Sleep Quality"
                                fetchBrainChartData()
                            }

                        FlatStatCard(title: "Source", value: "Apple Watch", tint: .blue)
                            .onTapGesture {
                                trendSelection = "Stress Level"
                                fetchBrainChartData()
                            }
                    }

                    brainTrendSection

                    // Brain-related tip card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Health Tip")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(healthTip)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))

                    // Spacer to avoid overlap with floating button
                    Color.clear.frame(height: 120)
                }
                .padding(.horizontal, 16)
            }

            // Floating voice button (long-press to show blue ripple)
            LongPressVoiceButton(isListening: $isListening,
                                 color: .blue,
                                 minDuration: 0.5,
                                 baseDiameter: 64,
                                 ringCount: 3) {
                print("🎙️ Long press recognized, start voice...")
            }
            .padding(.bottom, 22)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            fetchBrainChartData()
        }
    }

    private var brainTrendSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(trendSelection) Trend")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("View records by day, week, or month.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 12)
            }

            Picker("Range", selection: $selectedRange) {
                ForEach(BrainChartRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedRange) { _, _ in
                fetchBrainChartData()
            }

            if brainChartData.isEmpty {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 220)
                    .overlay(
                        Text(chartErrorMessage ?? "No trend data available yet.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    )
            } else {
                Chart(brainChartData) { point in
                    LineMark(
                        x: .value("Time", point.date),
                        y: .value(trendSelection, point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.blue)
                }
                .chartYAxisLabel(trendSelection == "Sleep Quality" ? "%" : "stress")
                .frame(height: 220)
                .padding(12)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
            }

            Button {
                fetchBrainChartData()
            } label: {
                Text("Refresh from Apple Watch")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundStyle(.white)
                    .background(Color.blue, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private func fetchBrainChartData() {
        if trendSelection == "Sleep Quality" {
            fetchSleepQualityChartData()
        } else {
            fetchStressLevelChartData()
        }
    }

    private func selectedStartDate() -> Date {
        let calendar = Calendar.current
        let now = Date()

        switch selectedRange {
        case .day:
            return calendar.date(byAdding: .day, value: -1, to: now) ?? now
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            return calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
    }

    private func fetchSleepQualityChartData() {
        guard HKHealthStore.isHealthDataAvailable() else {
            brainChartData = []
            chartErrorMessage = "Health data is not available on this device."
            return
        }

        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            brainChartData = []
            chartErrorMessage = "Sleep data type is not available."
            return
        }

        let now = Date()
        let predicate = HKQuery.predicateForSamples(
            withStart: selectedStartDate(),
            end: now,
            options: .strictStartDate
        )
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            DispatchQueue.main.async {
                if let error {
                    brainChartData = []
                    chartErrorMessage = "Failed to load sleep trend: \(error.localizedDescription)"
                    return
                }

                let sleepSamples = (samples as? [HKCategorySample] ?? []).filter { sample in
                    isAsleepSample(sample)
                }

                let groupedHours = groupSleepHoursByDay(samples: sleepSamples)
                brainChartData = groupedHours.map { date, hours in
                    BrainChartPoint(date: date, value: min(100, max(0, hours / 8.0 * 100.0)))
                }
                .sorted { $0.date < $1.date }

                chartErrorMessage = brainChartData.isEmpty ? "No Apple Watch sleep records found for this range." : nil
            }
        }

        healthStore.execute(query)
    }

    private func fetchStressLevelChartData() {
        guard HKHealthStore.isHealthDataAvailable() else {
            brainChartData = []
            chartErrorMessage = "Health data is not available on this device."
            return
        }

        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            brainChartData = []
            chartErrorMessage = "HRV data type is not available."
            return
        }

        let now = Date()
        let predicate = HKQuery.predicateForSamples(
            withStart: selectedStartDate(),
            end: now,
            options: .strictStartDate
        )
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(
            sampleType: hrvType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            DispatchQueue.main.async {
                if let error {
                    brainChartData = []
                    chartErrorMessage = "Failed to load stress trend: \(error.localizedDescription)"
                    return
                }

                let hrvSamples = samples as? [HKQuantitySample] ?? []
                let groupedStress = groupStressByDay(samples: hrvSamples)
                brainChartData = groupedStress.map { date, value in
                    BrainChartPoint(date: date, value: value)
                }
                .sorted { $0.date < $1.date }

                chartErrorMessage = brainChartData.isEmpty ? "No Apple Watch HRV records found for this range." : nil
            }
        }

        healthStore.execute(query)
    }

    private func isAsleepSample(_ sample: HKCategorySample) -> Bool {
        if #available(iOS 16.0, *) {
            return sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue ||
                sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue
        } else {
            return sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue
        }
    }

    private func groupSleepHoursByDay(samples: [HKCategorySample]) -> [(Date, Double)] {
        let calendar = Calendar.current
        var grouped: [Date: Double] = [:]

        for sample in samples {
            let day = calendar.startOfDay(for: sample.startDate)
            let hours = sample.endDate.timeIntervalSince(sample.startDate) / 3600.0
            grouped[day, default: 0] += hours
        }

        return grouped.map { ($0.key, $0.value) }
    }

    private func groupStressByDay(samples: [HKQuantitySample]) -> [(Date, Double)] {
        let calendar = Calendar.current
        var grouped: [Date: [Double]] = [:]

        for sample in samples {
            let day = calendar.startOfDay(for: sample.startDate)
            let hrvMs = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            grouped[day, default: []].append(hrvMs)
        }

        return grouped.map { date, values in
            let avgHRV = values.reduce(0, +) / Double(values.count)
            let stressScore = max(0, min(100, 100 - avgHRV))
            return (date, stressScore)
        }
    }
}

#if !os(watchOS)

private enum BrainChartRange: String, CaseIterable, Identifiable {
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

private struct BrainChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
#endif

#Preview {
    BrainHealthView()
}
