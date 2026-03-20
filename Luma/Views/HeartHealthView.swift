//
//  HeartHealthView.swift
//  Luma
//
//  Created by Jiaoyang Liu on 12/9/2025.
//

import SwiftUI

// MARK: - Main page
struct HeartHealthView: View {
    @State private var isListening = false
    @State private var trendSelection = "Heart Rate"
    @State private var healthTip = "Keep your Apple Watch snug on wrist for reliable heart-rate sampling."
    @State private var latestHeartRateBPM: Double?
    @State private var latestHeartRateTime: Date?
    @State private var isLoadingHeartRate = false
    @State private var heartRateError: String?
    private let gutter: CGFloat = 10
    var body: some View {
        HStack {
            Text("Your Health Manager")
                .font(.headline)
                .padding(.horizontal,gutter)
            Spacer()
            Button {
                print("🔔 Notification tapped")
            } label: {
                Image(systemName: "bell.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.orange)
            }
            .buttonStyle(.plain)

            // Avatar placeholder
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(Image(systemName: "person.fill").font(.caption))
                .padding(.horizontal,gutter)
        }
        .padding(.top, 8)
        ZStack(alignment: .bottom) {
            
            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    TopBadgeIcon(symbol: "stethoscope", color: .orange)
                        .frame(maxWidth: .infinity)

                    // cards
                    HStack(spacing: 12) {
                        FlatStatCard(
                            title: "Heart Rate",
                            value: heartRateDisplayText,
                            tint: .orange
                        )
                            .onTapGesture { trendSelection = "Heart Rate" }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Source")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Apple Watch")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.orange)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
                    }

                    // Trend placeholder (flat)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(trendSelection)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Picker("", selection: $trendSelection) {
                                Text("Heart Rate").tag("Heart Rate")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 160)
                        }

                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                            .frame(height: 220)
                            .overlay(
                                Text("📈 \(trendSelection) Chart")
                                    .foregroundColor(.secondary)
                            )
                    }

                    if let latestHeartRateTime {
                        Text("Last updated: \(latestHeartRateTime.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let heartRateError {
                        Text(heartRateError)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }

                    Button {
                        fetchLatestHeartRate()
                    } label: {
                        HStack(spacing: 8) {
                            if isLoadingHeartRate {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                            Text(isLoadingHeartRate ? "Refreshing..." : "Refresh from Apple Watch")
                                .font(.subheadline.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .disabled(isLoadingHeartRate)
                    .buttonStyle(.borderedProminent)
                    
                    // ✅ Health Tip card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Health Tip")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(healthTip)
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

            // Floating voice button (fixed at bottom-center)
            LongPressVoiceButton(isListening: $isListening,
                                 color: .orange,
                                 minDuration: 0.5,
                                 baseDiameter: 64,
                                 ringCount: 3) {
                // ✅ Action after long-press threshold (start voice recognition, etc.)
                print("🎙️ Long press recognized, start voice...")
            }
            .padding(.bottom, 22) // Leave space for the Home indicator
        }
        // Keep bottom button visible when keyboard appears
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            fetchLatestHeartRate()
        }
    }

    private var heartRateDisplayText: String {
        guard let latestHeartRateBPM else { return "-- bpm" }
        return String(format: "%.0f bpm", latestHeartRateBPM)
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
                    return
                }

                latestHeartRateBPM = reading.bpm
                latestHeartRateTime = reading.endDate
            }
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
