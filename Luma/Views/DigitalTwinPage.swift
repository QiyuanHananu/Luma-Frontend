//
//  DigitalTwinPage.swift
//  Luma
//
//  Created by Jiaoyang Liu on 3/9/2025.
//


import SwiftUI

struct DigitalTwinPage: View {
    @State private var navigateToHeartRate = false
    @State private var navigateToBrainHealth = false
    @State private var navigateToHeartHealth = false
    @State private var navigateToHRVHealth = false
    @State private var statusPhase = 0
    @State private var statusTimer: Timer?

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
        .sheet(isPresented: $navigateToBrainHealth) {
            BrainHealthView()
        }
        .sheet(isPresented: $navigateToHeartHealth) {
            HeartHealthView()
        }
        .sheet(isPresented: $navigateToHRVHealth) {
            HRVHealthView()
        }
        .onAppear {
            if statusTimer == nil {
                statusTimer = Timer.scheduledTimer(withTimeInterval: 2.4, repeats: true) { _ in
                    var transaction = Transaction()
                    transaction.animation = nil
                    withTransaction(transaction) {
                        statusPhase = (statusPhase + 1) % 3
                    }
                }
            }
        }
        .onDisappear {
            statusTimer?.invalidate()
            statusTimer = nil
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
                        systemImage: "brain.head.profile",
                        action: { navigateToBrainHealth = true }
                    )
                    .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.08)

                    healthPoint(
                        systemImage: "heart.fill",
                        action: { navigateToHeartHealth = true }
                    )
                    .position(x: proxy.size.width * 0.54, y: proxy.size.height * 0.25)

                    healthPoint(
                        systemImage: "waveform.path.ecg",
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
                Text(status.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(status.message)
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
        switch statusPhase {
        case 1:
            return (
                "Warning signal",
                "Yellow indicates a metric may need attention soon.",
                "exclamationmark.triangle.fill",
                Color.orange
            )
        case 2:
            return (
                "Critical signal",
                "Red indicates a higher-priority health insight.",
                "cross.case.fill",
                Color.red
            )
        default:
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
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 34, height: 34)
                    .blur(radius: 1.5)

                Circle()
                    .stroke(Color.green.opacity(0.26), lineWidth: 1)
                    .frame(width: 28, height: 28)

                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                    .shadow(color: Color.green.opacity(0.45), radius: 6, x: 0, y: 0)

                Image(systemName: systemImage)
                    .font(.system(size: 6, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))
            }
            .frame(width: 44, height: 44)
            .contentShape(Circle())
            .accessibilityLabel("Health insight point")
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DigitalTwinPage()
}
