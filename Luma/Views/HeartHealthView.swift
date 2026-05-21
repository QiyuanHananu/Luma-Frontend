//
//  HeartHealthView.swift
//  Luma
//
//  Created by Jiaoyang Liu on 12/9/2025.
//

import SwiftUI
import Charts
import HealthKit

// MARK: - Main page
struct HeartHealthView: View {
    @State private var isListening = false
    @State private var healthTip = "Loading personalized health tip..."
    @State private var latestHeartRateBPM: Double?
    @State private var latestHeartRateTime: Date?
    @State private var isLoadingHeartRate = false
    @State private var heartRateError: String?
    @State private var selectedRange: HeartRateChartRange = .day
    @State private var heartRateChartData: [HeartRateChartPoint] = []
    private let gutter: CGFloat = 10
    private let healthStore = HKHealthStore()

    private var isRunningInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        TopBadgeIcon(symbol: "heart.fill", color: .orange)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)

                        summaryCards

                        heartRateTrendSection

                        if let heartRateError {
                            Text(heartRateError)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.horizontal, 2)
                        }

                        PressableDimRefreshControl(
                            title: isLoadingHeartRate ? "Refreshing..." : "Refresh from Apple Watch",
                            tint: .orange,
                            isLoading: isLoadingHeartRate,
                            isDisabled: isLoadingHeartRate
                        ) {
                            fetchLatestHeartRate()
                        }

                        healthTipCard

                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            if isRunningInPreview {
                loadPreviewData()
            } else {
                fetchLatestHeartRate()
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
                title: "Heart Rate",
                value: heartRateDisplayText,
                tint: .orange
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Source")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Apple Watch")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.orange)
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

    private var heartRateDisplayText: String {
        guard let latestHeartRateBPM else { return "-- bpm" }
        return String(format: "%.0f bpm", latestHeartRateBPM)
    }


    private var heartRateTrendSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Heart Rate Trend")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("View your heart-rate records by day, week, or month.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Picker("Heart-rate range", selection: $selectedRange) {
                ForEach(HeartRateChartRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedRange) { _, _ in
                fetchHeartRateChartData()
            }

            VStack(spacing: 8) {
                if heartRateChartData.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.title2)
                            .foregroundColor(.secondary.opacity(0.7))

                        Text("No heart-rate trend data available yet.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    heartRateBarChart
                }

                if let latestHeartRateTime {
                    Text("Last updated: \(latestHeartRateTime.formatted(date: .abbreviated, time: .shortened))")
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

    private var heartRateBarChart: some View {
        let maxValue = max(heartRateChartData.map(\.bpm).max() ?? 120, 120)
        let displayPoints = compactedHeartRateChartData

        return HStack(alignment: .bottom, spacing: selectedRange == .month ? 4 : 10) {
            ForEach(displayPoints) { point in
                VStack(spacing: 6) {
                    Text(String(format: "%.0f", point.bpm))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.orange)
                        .lineLimit(1)

                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.85), Color.orange.opacity(0.28)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: max(18, CGFloat(point.bpm / maxValue) * 108))

                    Text(chartLabel(for: point.date))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }

    private var compactedHeartRateChartData: [HeartRateChartPoint] {
        switch selectedRange {
        case .day:
            return Array(heartRateChartData.suffix(6))
        case .week:
            return compactChartData(targetCount: 7)
        case .month:
            return compactChartData(targetCount: 4)
        }
    }

    private func compactChartData(targetCount: Int) -> [HeartRateChartPoint] {
        guard heartRateChartData.count > targetCount else { return heartRateChartData }

        let chunkSize = Double(heartRateChartData.count) / Double(targetCount)
        return (0..<targetCount).compactMap { index in
            let start = Int(Double(index) * chunkSize)
            let end = min(Int(Double(index + 1) * chunkSize), heartRateChartData.count)
            let chunk = Array(heartRateChartData[start..<max(start + 1, end)])
            guard let representative = chunk.last else { return nil }
            let average = chunk.map(\.bpm).reduce(0, +) / Double(chunk.count)
            return HeartRateChartPoint(date: representative.date, bpm: average)
        }
    }

    private func chartLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current

        switch selectedRange {
        case .day:
            formatter.dateFormat = "ha"
        case .week:
            formatter.dateFormat = "E"
        case .month:
            formatter.dateFormat = "M/d"
        }

        return formatter.string(from: date)
    }

    private func loadPreviewData() {
        latestHeartRateBPM = 78
        latestHeartRateTime = Date()
        heartRateError = nil
        isLoadingHeartRate = false
        healthTip = "Your heart rate looks stable. Keep your Apple Watch snug for reliable readings."

        let now = Date()
        heartRateChartData = [
            HeartRateChartPoint(date: now.addingTimeInterval(-60 * 60 * 6), bpm: 72),
            HeartRateChartPoint(date: now.addingTimeInterval(-60 * 60 * 5), bpm: 76),
            HeartRateChartPoint(date: now.addingTimeInterval(-60 * 60 * 4), bpm: 80),
            HeartRateChartPoint(date: now.addingTimeInterval(-60 * 60 * 3), bpm: 74),
            HeartRateChartPoint(date: now.addingTimeInterval(-60 * 60 * 2), bpm: 82),
            HeartRateChartPoint(date: now.addingTimeInterval(-60 * 60), bpm: 78)
        ]
    }

    private func fetchHeartRateChartData() {
        guard HKHealthStore.isHealthDataAvailable() else {
            heartRateChartData = []
            heartRateError = "Health data is not available on this device."
            return
        }

        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            heartRateChartData = []
            heartRateError = "Heart-rate data type is not available."
            return
        }

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

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: true
        )

        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            DispatchQueue.main.async {
                if let error {
                    heartRateChartData = []
                    heartRateError = "Failed to load heart-rate trend: \(error.localizedDescription)"
                    return
                }

                let quantitySamples = samples as? [HKQuantitySample] ?? []
                let watchSamples = quantitySamples.filter { sample in
                    isAppleWatchSample(sample)
                }

                // Prefer Apple Watch samples. If source metadata is unavailable,
                // fall back to all heart-rate samples already synced into Apple Health.
                let displaySamples = watchSamples.isEmpty ? quantitySamples : watchSamples

                heartRateChartData = displaySamples.map { sample in
                    HeartRateChartPoint(
                        date: sample.startDate,
                        bpm: sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    )
                }

                if heartRateChartData.isEmpty {
                    heartRateError = "No Apple Watch heart-rate trend samples found for this range."
                } else if heartRateError?.hasPrefix("No Apple Watch heart-rate") == true || heartRateError?.hasPrefix("Failed to load heart-rate trend") == true {
                    heartRateError = nil
                }
            }
        }

        healthStore.execute(query)
    }

    private func isAppleWatchSample(_ sample: HKQuantitySample) -> Bool {
        let sourceName = sample.sourceRevision.source.name.lowercased()
        let productType = sample.sourceRevision.productType?.lowercased() ?? ""
        let deviceName = sample.device?.name?.lowercased() ?? ""
        let deviceManufacturer = sample.device?.manufacturer?.lowercased() ?? ""

        return productType.hasPrefix("watch") ||
            productType.contains("watch") ||
            sourceName.contains("watch") ||
            deviceName.contains("watch") ||
            deviceManufacturer.contains("apple")
    }

    private func fetchLatestHeartRate() {
        isLoadingHeartRate = true
        heartRateError = nil

        HealthKitManager.shared.fetchLatestHeartRate { reading in
            DispatchQueue.main.async {
                isLoadingHeartRate = false

                guard let reading else {
                    latestHeartRateBPM = nil
                    latestHeartRateTime = nil
                    heartRateError = "No Apple Watch heart-rate sample found yet. Open Health app and grant Heart Rate read permission."
                    healthTip = "Wear your Apple Watch consistently to generate heart-rate insights."
                    fetchHeartRateChartData()
                    return
                }

                latestHeartRateBPM = reading.bpm
                latestHeartRateTime = reading.endDate
                fetchHeartRateChartData()
                healthTip = "Generating personalized health tip..."
                Task {
                    await updateHealthTip(for: reading.bpm)
                }

                Task {
                    await HealthMetricsService.shared.uploadHeartRate(
                        bpm: reading.bpm,
                        sampledAt: reading.endDate
                    )
                }
            }
        }
    }

    private func updateHealthTip(for bpm: Double) async {
        do {
            let response: HeartHealthTipResponse = try await APIClient.shared.request(
                path: "/api/health/tip/",
                method: "POST",
                body: HeartHealthTipRequest(
                    metric: "heart_rate",
                    value: bpm,
                    status: heartRateStatus(for: bpm),
                    context: "Latest Apple Watch heart-rate reading"
                ),
                requiresAuth: false
            )

            await MainActor.run {
                healthTip = response.tip
            }
        } catch {
            print("❌ Failed to generate heart-rate health tip:", error.localizedDescription)
            await MainActor.run {
                healthTip = fallbackHeartRateTip(for: bpm)
            }
        }
    }

    private func heartRateStatus(for bpm: Double) -> String {
        if bpm < 50 || bpm > 120 {
            return "critical"
        }

        if bpm > 100 {
            return "warning"
        }

        return "normal"
    }

    private func fallbackHeartRateTip(for bpm: Double) -> String {
        if bpm < 50 {
            return "Your heart rate looks lower than usual. If you feel dizzy or unwell, consider seeking medical advice."
        }

        if bpm > 110 {
            return "Your heart rate looks elevated. Try resting, hydrating, and checking again later."
        }

        return "Your heart rate looks stable. Keep your Apple Watch snug for reliable readings."
    }
// MARK: - HeartHealthTip API models
private struct HeartHealthTipRequest: Encodable {
    let metric: String
    let value: Double?
    let status: String
    let context: String?
}

private struct HeartHealthTipResponse: Decodable {
    let tip: String
    let fallbackTip: String?
    let source: String?

    enum CodingKeys: String, CodingKey {
        case tip
        case fallbackTip = "fallback_tip"
        case source
    }
}
}

// MARK: - Reusable top badge icon with halo
struct TopBadgeIcon: View {
    let symbol: String
    let color: Color

    // Tunables
    var haloDiameter: CGFloat = 180          // halo
    var iconSize: CGFloat = 120              // label
    var glowOpacity: CGFloat = 0.18          // halo opacity
    var haloEndRadius: CGFloat = 100         // halo radius
    var mode: SymbolRenderingMode = .palette // .palette / .hierarchical / .multicolor
    var mono: Bool = false

    var body: some View {
        ZStack {
            // Halo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(glowOpacity), .clear],
                        center: .center,
                        startRadius: 2, endRadius: haloEndRadius
                    )
                )
                .frame(width: haloDiameter, height: haloDiameter)

            // Icon
            Image(systemName: symbol)
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(mode)
                .foregroundStyle(mono ? AnyShapeStyle(color) : AnyShapeStyle(.white), AnyShapeStyle(color))
                .frame(width: iconSize, height: iconSize)
                .shadow(color: color.opacity(0.25), radius: 12, y: 4)
        }
    }
}

// MARK: - Flat statistic card
struct FlatStatCard: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(title).font(.subheadline).foregroundColor(.secondary)
            }
            Text(value)
                .font(.title2).bold()
                .foregroundColor(tint)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
    }
}

// MARK: - Floating voice button (with subtle pulse animation)
struct LongPressVoiceButton: View {
    @Binding var isListening: Bool
    var color: Color = .clear
    var minDuration: Double = 0.5       // Long-press threshold (seconds)
    var baseDiameter: CGFloat = 64      // Base diameter for ripple (≈ button size)
    var ringCount: Int = 3              // Number of simultaneous rings
    var action: () -> Void              // Callback after successful long-press (start ASR, etc.)

    var body: some View {
        ZStack {
            // Show ripples only while pressing
            if isListening {
                GlowPulse(color: color, base: baseDiameter, ringCount: ringCount)
                    .allowsHitTesting(false)
            }

            Button {
                // No tap action; use long-press to avoid accidental triggers
            } label: {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 56))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, color)
                    .shadow(radius: 4, y: 1)
            }
            // Long-press gesture: show ripples while pressed; perform action after threshold
            .onLongPressGesture(minimumDuration: minDuration,
                                maximumDistance: 30,
                                perform: {
                                    action()
                                    // If you want the ripples to stay briefly after release, close with a short delay:
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        withAnimation(.easeOut) { isListening = false }
                                    }
                                },
                                onPressingChanged: { pressing in
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        isListening = pressing
                                    }
                                })
            .accessibilityLabel("Voice Input (Long Press)")
        }
    }
}



// MARK: - Metric card
struct MetricCard: View {
    var title: String
    var value: String
    var tint: Color = .accentColor
    var icon: String? = nil         // Optional SF Symbol; pass nil to hide
    var subtitle: String? = nil     // Optional subtitle
        
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
            
            Text(value)
                .font(.title2).bold()
                .foregroundStyle(tint)
            
            if let subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 0.5)   // Thin stroke
    )
        .cornerRadius(12)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .buttonStyle(.plain)
    }
}
   

// MARK: - Center-outward glowing ripple
struct GlowPulse: View {
    var color: Color = .pink
    var base: CGFloat = 48            // Base diameter (≈ button size)
    var ringCount: Int = 3            // Number of simultaneous rings
    var maxScale: CGFloat = 1.5       // Target scale at the end of expansion
    var lineWidth: CGFloat = 6
    
    @State private var anim = false
    
    var body: some View {
        ZStack {
            ForEach(0..<ringCount, id: \.self) { i in
                Circle()
                    .stroke(color.opacity(0.55), lineWidth: lineWidth)
                    .frame(width: base, height: base)
                    .scaleEffect(anim ? maxScale : 0.6)
                    .opacity(anim ? 0.0 : 1.0)
                    .blur(radius: 1.2)
                    .shadow(color: color.opacity(0.6), radius: 8)     // Outer glow
                    .animation(
                        .easeOut(duration: 1.6)
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * 0.25),                      // Staggered delays
                        value: anim
                    )
            }
            // Extra inner glow: soft base halo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.28), .clear],
                        center: .center, startRadius: 1.5, endRadius: base
                    )
                )
                .frame(width: base * 1.2, height: base * 1.2)
                .blur(radius: 10)
                .blendMode(.plusLighter) // Additive blend for stronger glow
                .opacity(0.9)
        }
        .blendMode(.plusLighter) // Make overlapping rings brighter
        .onAppear { anim = true }
        .onDisappear { anim = false }
    }
}


// MARK: - Flat container card
struct FlatContainerCard<Content: View>: View {
    var content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.separator), lineWidth: 1)
            )
            .cornerRadius(12)
    }
}
#Preview {
    HeartHealthView()
}


private enum HeartRateChartRange: String, CaseIterable, Identifiable {
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

private struct HeartRateChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let bpm: Double
}

// Custom refresh control for new design
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
