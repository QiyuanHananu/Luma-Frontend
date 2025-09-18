//
//  BrainHealthView.swift
//  Luma
//
//  Created by Jiaoyang Liu on 11/9/2025.
//


import SwiftUI

// MARK: - Brain Health (blue & white theme)
struct BrainHealthView: View {
    @State private var isListening = false
    @State private var trendSelection = "Sleep Quality"
    @State private var healthTip = "Your sleep duration improved this week. Keep the habit!"

    var body: some View {
            
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 20) {

                // Top bar
                HStack {
                    Text("    Brain Health")
                        .font(.headline)
                    Spacer()
                    Button {
                        print("🔔 Notification tapped")
                    } label: {
                        Image(systemName: "bell")
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

            // Scrollable content
            ScrollView {

                    // Brain icon + halo
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.blue.opacity(0.18), .clear],
                                    center: .center, startRadius: 2, endRadius: 120
                                )
                            )
                            .frame(width: 220, height: 220)

                        if UIImage(named: "brainIcon") != nil {
                            Image("brainIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .shadow(color: .blue.opacity(0.35), radius: 20)
                        } else {
                            Image(systemName: "brain")
                                .resizable()
                                .scaledToFit()
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.blue)
                                .frame(width: 120, height: 120)
                                .shadow(color: .blue.opacity(0.35), radius: 20)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Cards row (Sleep Quality / Stress Level)
                    HStack(spacing: 12) {
                        FlatStatCard(title: "Sleep Quality", value: "85%", tint: .blue)
                            .onTapGesture { trendSelection = "Sleep Quality" }

                        FlatStatCard(title: "Stress Level", value: "Low", tint: .blue)
                            .onTapGesture { trendSelection = "Stress Level" }
                    }

                    // Trend section (blue/white)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(trendSelection)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Picker("", selection: $trendSelection) {
                                Text("Sleep Quality").tag("Sleep Quality")
                                Text("Stress Level").tag("Stress Level")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 260)
                        }

                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                            .frame(height: 220)
                            .overlay(
                                Text("📈 \(trendSelection) Trend")
                                    .foregroundColor(.secondary)
                            )
                    }

                    // Brain-related tip card
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
    }
}
#Preview {
    BrainHealthView()
}
