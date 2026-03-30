//
//  HRVHealthView.swift
//  Luma
//

import SwiftUI

struct HRVHealthView: View {
    @State private var isListening = false
    @State private var latestHRVMS: Double?
    @State private var latestUpdateTime: Date?
    @State private var isLoading = false
    @State private var errorMessage: String?
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
                    return
                }

                latestHRVMS = value
                latestUpdateTime = Date()

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

#Preview {
    HRVHealthView()
}
