//
//  DigitalTwinPage.swift
//  Luma
//
//  Created by Jiaoyang Liu on 3/9/2025.
//


import SwiftUI
import HealthKit

struct DigitalTwinPage: View {
    @State private var navigateToHeartRate = false
    @State private var navigateToSleepHealth = false
    @State private var navigateToHeartHealth = false
    @State private var navigateToHRVHealth = false
    @State private var overallStatus: DigitalTwinHealthStatus = .normal
    @State private var overallScore: Int?
    @State private var statusSummary = "Your current health signals look stable."
    @State private var metricAssessments: [DigitalTwinMetricAssessment] = []
    @State private var isLoadingAssessment = false
    @State private var displayedHeartRate: Double?
    @State private var displayedHRV: Double?
    @State private var displayedSleepHours: Double?
    private let healthStore = HKHealthStore()

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 18) {
                headerSection
                    .padding(.horizontal, 24)
                    .padding(.top, 18)

                digitalTwinStage
                    .padding(.horizontal, 20)

                insightHint
                    .padding(.horizontal, 24)
                    .padding(.bottom, 18)
            }
        }
        .sheet(isPresented: $navigateToSleepHealth) {
            SleepHealthView()
        }
        .sheet(isPresented: $navigateToHeartHealth) {
            HeartHealthView()
        }
        .sheet(isPresented: $navigateToHRVHealth) {
            HRVHealthView()
        }
        .onAppear {
            Task {
                await refreshHealthAssessment()
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.94, green: 0.98, blue: 0.97),
                Color(red: 0.98, green: 0.99, blue: 1.00),
                Color(red: 0.91, green: 0.95, blue: 0.99)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.title2)
                    .foregroundStyle(Color.green)

                Text("Luma Digital Twin")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Spacer()
            }

            Text("Tap glowing health points to explore body-based insights.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var digitalTwinStage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.white.opacity(0.78))
                .shadow(color: Color.blue.opacity(0.10), radius: 22, x: 0, y: 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.9), lineWidth: 1)
                )

            GeometryReader { proxy in
                ZStack {
                    Image("image")
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width * 1.18, height: proxy.size.height * 1.28)
                        .position(x: proxy.size.width * 0.50, y: proxy.size.height * 0.53)

                    healthPoint(
                        systemImage: "bed.double.fill",
                        status: statusForMetric("sleep"),
                        valueText: formattedSleepHours,
                        action: { navigateToSleepHealth = true }
                    )
                    .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.08)

                    healthPoint(
                        systemImage: "heart.fill",
                        status: statusForMetric("heart_rate"),
                        valueText: formattedHeartRate,
                        action: { navigateToHeartHealth = true }
                    )
                    .position(x: proxy.size.width * 0.54, y: proxy.size.height * 0.25)

                    healthPoint(
                        systemImage: "waveform.path.ecg",
                        status: statusForMetric("hrv"),
                        valueText: formattedHRV,
                        action: { navigateToHRVHealth = true }
                    )
                    .position(x: proxy.size.width * 0.47, y: proxy.size.height * 0.30)
                }
            }
            .padding(16)
        }
        .frame(minHeight: 500)
    }

    private var neutralHumanSilhouette: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.78, green: 0.88, blue: 0.90).opacity(0.75),
                            Color(red: 0.88, green: 0.95, blue: 0.94).opacity(0.55)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 76, height: 210)
                .offset(y: 52)
                .overlay(
                    Capsule()
                        .stroke(Color.green.opacity(0.16), lineWidth: 1.2)
                        .frame(width: 76, height: 210)
                        .offset(y: 52)
                )

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.80, green: 0.91, blue: 0.91).opacity(0.82),
                            Color.white.opacity(0.70)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 72, height: 72)
                .offset(y: -96)
                .overlay(
                    Circle()
                        .stroke(Color.green.opacity(0.18), lineWidth: 1.2)
                        .frame(width: 72, height: 72)
                        .offset(y: -96)
                )

            Capsule()
                .fill(Color(red: 0.72, green: 0.84, blue: 0.88).opacity(0.30))
                .frame(width: 34, height: 158)
                .rotationEffect(.degrees(10))
                .offset(x: -64, y: 58)

            Capsule()
                .fill(Color(red: 0.72, green: 0.84, blue: 0.88).opacity(0.30))
                .frame(width: 34, height: 158)
                .rotationEffect(.degrees(-10))
                .offset(x: 64, y: 58)

            Capsule()
                .fill(Color(red: 0.72, green: 0.84, blue: 0.88).opacity(0.28))
                .frame(width: 30, height: 150)
                .rotationEffect(.degrees(5))
                .offset(x: -24, y: 208)

            Capsule()
                .fill(Color(red: 0.72, green: 0.84, blue: 0.88).opacity(0.28))
                .frame(width: 30, height: 150)
                .rotationEffect(.degrees(-5))
                .offset(x: 24, y: 208)

            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .stroke(Color.white.opacity(0.65), lineWidth: 1)
                .frame(width: 118, height: 300)
                .offset(y: 58)
                .blur(radius: 0.5)
        }
        .frame(width: 220, height: 390)
        .shadow(color: Color.green.opacity(0.12), radius: 18, x: 0, y: 10)
    }

    private var insightHint: some View {
        let status = currentStatus

        return HStack(spacing: 12) {
            Circle()
                .fill(status.color.opacity(0.16))
                .frame(width: 40, height: 40)
                .overlay(
                    ZStack {
                        Circle()
                            .stroke(status.color.opacity(0.30), lineWidth: 1)
                            .frame(width: 30, height: 30)
                        Image(systemName: status.icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(status.color)
                    }
                )
                .shadow(color: status.color.opacity(0.25), radius: 8, x: 0, y: 0)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(status.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if let overallScore {
                        Text("Score \(overallScore)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(status.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(status.color.opacity(0.12), in: Capsule())
                    }

                    if isLoadingAssessment {
                        ProgressView()
                            .scaleEffect(0.65)
                    }
                }

                Text(statusSummary.isEmpty ? status.message : statusSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .frame(height: 78)
        .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(status.color.opacity(0.26), lineWidth: 1)
        )
        .shadow(color: status.color.opacity(0.10), radius: 14, x: 0, y: 8)
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    private var currentStatus: (title: String, message: String, icon: String, color: Color) {
        switch overallStatus {
        case .critical:
            return (
                "Critical signal",
                "Red indicates a higher-priority health insight.",
                "cross.case.fill",
                Color.red
            )
        case .warning:
            return (
                "Warning signal",
                "Yellow indicates a metric may need attention soon.",
                "exclamationmark.triangle.fill",
                Color.orange
            )
        case .unknown:
            return (
                "No signal yet",
                "Connect health data to generate a Digital Twin assessment.",
                "questionmark.circle.fill",
                Color.gray
            )
        case .normal:
            return (
                "Healthy baseline",
                "Green indicates stable signals and available insights.",
                "sparkles",
                Color.green
            )
        }
    }

    private func healthPoint(
        systemImage: String,
        status: DigitalTwinHealthStatus,
        valueText: String?,
        action: @escaping () -> Void
    ) -> some View {
        let pointColor = colorForStatus(status)
        return Button(action: action) {
            VStack(spacing: 1) {
                ZStack {
                    Circle()
                        .fill(pointColor.opacity(0.14))
                        .frame(width: 18, height: 18)
                        .blur(radius: 1.2)

                    Circle()
                        .stroke(pointColor.opacity(0.32), lineWidth: 0.8)
                        .frame(width: 14, height: 14)

                    Circle()
                        .fill(pointColor)
                        .frame(width: 7, height: 7)
                        .shadow(color: pointColor.opacity(0.48), radius: 5, x: 0, y: 0)
                }
                .frame(width: 26, height: 26)
                // Removed valueText label for visual simplification
            }
            .contentShape(Rectangle())
            .accessibilityLabel("Health insight point")
        }
        .buttonStyle(.plain)
    }


    private func refreshHealthAssessment() async {
        await MainActor.run {
            isLoadingAssessment = true
        }

        defer {
            Task { @MainActor in
                isLoadingAssessment = false
            }
        }

        do {
            try await requestHealthAuthorizationIfNeeded()

            let latestHeartRate = try? await fetchLatestHeartRateBPM()
            let latestHRV = try? await fetchLatestHRVMS()
            let latestSleepHours = try? await fetchSleepHoursInLastDay()

            print("🩺 Digital Twin values:", latestHeartRate as Any, latestHRV as Any, latestSleepHours as Any)

            let response: DigitalTwinHealthAssessmentResponse = try await APIClient.shared.request(
                path: "/api/health/assess/",
                method: "POST",
                body: DigitalTwinHealthAssessmentRequest(
                    heartRate: latestHeartRate,
                    hrv: latestHRV,
                    sleepHours: latestSleepHours
                ),
                requiresAuth: false
            )

            await MainActor.run {
                displayedHeartRate = latestHeartRate
                displayedHRV = latestHRV
                displayedSleepHours = latestSleepHours
                overallStatus = DigitalTwinHealthStatus(rawValue: response.overallStatus) ?? .unknown
                overallScore = response.score
                statusSummary = response.summary
                metricAssessments = response.metrics
            }
        } catch {
            print("❌ Failed to load Digital Twin health assessment:", error.localizedDescription)
            await MainActor.run {
                displayedHeartRate = nil
                displayedHRV = nil
                displayedSleepHours = nil
                overallStatus = .unknown
                overallScore = nil
                statusSummary = "Could not load health assessment right now."
                metricAssessments = []
            }
        }
    }

    private func requestHealthAuthorizationIfNeeded() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        var readTypes = Set<HKObjectType>()

        if let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) {
            readTypes.insert(heartRateType)
        }

        if let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            readTypes.insert(hrvType)
        }

        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            readTypes.insert(sleepType)
        }

        guard !readTypes.isEmpty else { return }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: DigitalTwinHealthKitError.authorizationDenied)
                }
            }
        }
    }

    private func fetchLatestHeartRateBPM() async throws -> Double? {
        guard let type = HKObjectType.quantityType(forIdentifier: .heartRate) else { return nil }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let unit = HKUnit.count().unitDivided(by: .minute())
                continuation.resume(returning: sample.quantity.doubleValue(for: unit))
            }

            healthStore.execute(query)
        }
    }

    private func fetchLatestHRVMS() async throws -> Double? {
        guard let type = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return nil }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: sample.quantity.doubleValue(for: .secondUnit(with: .milli)))
            }

            healthStore.execute(query)
        }
    }

    private func fetchSleepHoursInLastDay() async throws -> Double? {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }

        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startDate = calendar.date(byAdding: .hour, value: -6, to: startOfToday) ?? now.addingTimeInterval(-30 * 60 * 60)
        let endDate = now

        // Use overlapping samples instead of strict end-date matching.
        // Apple Health often stores overnight sleep with segments crossing midnight.
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let sleepSamples = (samples as? [HKCategorySample]) ?? []
                let asleepRawValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue
                ]

                let asleepSeconds = sleepSamples.reduce(0.0) { total, sample in
                    guard asleepRawValues.contains(sample.value) else { return total }

                    let clippedStart = max(sample.startDate, startDate)
                    let clippedEnd = min(sample.endDate, endDate)
                    let duration = clippedEnd.timeIntervalSince(clippedStart)

                    guard duration > 0 else { return total }
                    return total + duration
                }

                print("😴 Sleep samples:", sleepSamples.count, "hours:", asleepSeconds / 3600.0)

                guard asleepSeconds > 0 else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: asleepSeconds / 3600.0)
            }

            healthStore.execute(query)
        }
    }

    private var formattedSleepHours: String? {
        guard let displayedSleepHours else { return nil }
        return String(format: "%.1fh", displayedSleepHours)
    }

    private var formattedHeartRate: String? {
        guard let displayedHeartRate else { return nil }
        return String(format: "%.0fbpm", displayedHeartRate)
    }

    private var formattedHRV: String? {
        guard let displayedHRV else { return nil }
        return String(format: "%.0fms", displayedHRV)
    }

    private func statusForMetric(_ metric: String) -> DigitalTwinHealthStatus {
        guard let assessment = metricAssessments.first(where: { $0.metric == metric }) else {
            return .normal
        }
        return DigitalTwinHealthStatus(rawValue: assessment.status) ?? .unknown
    }

    private func colorForStatus(_ status: DigitalTwinHealthStatus) -> Color {
        switch status {
        case .critical:
            return .red
        case .warning:
            return .orange
        case .unknown:
            return .gray
        case .normal:
            return .green
        }
    }
}

private enum DigitalTwinHealthStatus: String {
    case normal
    case warning
    case critical
    case unknown
}

private struct DigitalTwinHealthAssessmentRequest: Encodable {
    let heartRate: Double?
    let hrv: Double?
    let sleepHours: Double?

    enum CodingKeys: String, CodingKey {
        case heartRate = "heart_rate"
        case hrv
        case sleepHours = "sleep_hours"
    }
}

private struct DigitalTwinHealthAssessmentResponse: Decodable {
    let overallStatus: String
    let score: Int?
    let summary: String
    let metrics: [DigitalTwinMetricAssessment]

    enum CodingKeys: String, CodingKey {
        case overallStatus = "overall_status"
        case score
        case summary
        case metrics
    }
}

private struct DigitalTwinMetricAssessment: Decodable, Identifiable {
    var id: String { metric }
    let metric: String
    let status: String
    let value: Double?
    let score: Int?
    let message: String
}

private enum DigitalTwinHealthKitError: Error {
    case authorizationDenied
}

#Preview {
    DigitalTwinPage()
}
