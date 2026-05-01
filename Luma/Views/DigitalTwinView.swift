import SwiftUI

struct DigitalTwinView: View {
    @State private var selectedInsight: InsightItem? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Overall dark background
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.08, blue: 0.13),
                        Color(red: 0.08, green: 0.13, blue: 0.20),
                        Color(red: 0.02, green: 0.04, blue: 0.08)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerSection

                    bodyModelSection
                        .frame(height: geo.size.height * 0.72)

                    combinedInsightsSection
                }
            }
        }
        .sheet(item: $selectedInsight) { insight in
            InsightBottomSheet(insight: insight)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var headerSection: some View {
        Text("Digital Twin")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 22)
            .padding(.top, 14)
            .padding(.bottom, 8)
    }

    private var bodyModelSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.04, green: 0.11, blue: 0.18),
                            Color(red: 0.09, green: 0.16, blue: 0.25),
                            Color(red: 0.04, green: 0.08, blue: 0.14)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .cyan.opacity(0.14), radius: 18, x: 0, y: 10)

            VStack {
                HStack(alignment: .top) {
                    Text("Your body signals, mapped into one interactive wellbeing view.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                        .lineSpacing(2)
                        .frame(width: 118, alignment: .leading)
                        .padding(.top, 18)
                        .padding(.leading, 8)

                    Spacer()
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            // Replace this system image with your actual human body asset if you have one.
            // Example:
            // Image("body_model")
            //     .resizable()
            //     .scaledToFit()
            Image(systemName: "figure.stand")
                .resizable()
                .scaledToFit()
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color.cyan.opacity(0.55),
                            Color.blue.opacity(0.35)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .cyan.opacity(0.45), radius: 22)
                .shadow(color: .white.opacity(0.18), radius: 10)
                .padding(.vertical, 22)
                .padding(.horizontal, 42)

            // Metric pins
            MetricBubble(
                title: "Sleep",
                value: "5.4h",
                statusColor: .red
            )
            .offset(x: 0, y: -165)

            MetricBubble(
                title: "HRV",
                value: "28 ms",
                statusColor: .red
            )
            .offset(x: -70, y: -82)

            MetricBubble(
                title: "SpO2",
                value: "97%",
                statusColor: .blue
            )
            .offset(x: 70, y: -75)

            MetricBubble(
                title: "HR",
                value: "102 bpm",
                statusColor: .red
            )
            .offset(x: 0, y: -28)

            MetricBubble(
                title: "Steps",
                value: "3.8k",
                statusColor: .yellow
            )
            .offset(x: 0, y: 168)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }

    private var combinedInsightsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("Combined Insights")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Image(systemName: "info.circle")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(InsightItem.sampleData) { insight in
                        InsightCard(insight: insight)
                            .onTapGesture {
                                selectedInsight = insight
                            }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 14)
        .background(
            Color(.systemBackground)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 24,
                        topTrailingRadius: 24
                    )
                )
        )
    }
}

struct MetricBubble: View {
    let title: String
    let value: String
    let statusColor: Color

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 14, height: 14)
                .shadow(color: statusColor.opacity(0.7), radius: 8)

            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
        }
    }
}

struct InsightCard: View {
    let insight: InsightItem

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Circle()
                    .fill(insight.statusColor)
                    .frame(width: 8, height: 8)

                Text(insight.title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer()
            }

            Text(insight.shortSummary)
                .font(.caption2)
                .foregroundColor(.primary.opacity(0.85))
                .lineLimit(2)

            Text(insight.recommendationPreview)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Spacer(minLength: 2)

            Text("View details")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(12)
        .frame(width: 160, height: 116)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

struct InsightBottomSheet: View {
    let insight: InsightItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text(insight.title)
                                .font(.title2)
                                .fontWeight(.bold)

                            Circle()
                                .fill(insight.statusColor)
                                .frame(width: 10, height: 10)
                        }

                        Text(insight.statusText)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(insight.statusColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(insight.statusColor.opacity(0.14))
                            .clipShape(Capsule())
                    }

                    Spacer()
                }

                whyAppearedSection

                detailTextSection(
                    title: "Observation",
                    content: insight.observation
                )

                detailTextSection(
                    title: "Interpretation",
                    content: insight.interpretation
                )

                detailTextSection(
                    title: "Recommendation",
                    content: insight.recommendation
                )

                relatedMetricsSection

                aiSummarySection
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }

    private var whyAppearedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Why this insight appeared")
                .font(.subheadline)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(insight.reasons, id: \.self) { reason in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.secondary)

                        Text(reason)
                            .font(.subheadline)
                            .foregroundColor(.primary.opacity(0.85))
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func detailTextSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)

            Text(content)
                .font(.subheadline)
                .foregroundColor(.primary.opacity(0.85))
                .lineSpacing(4)
        }
    }

    private var relatedMetricsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Related Metrics")
                .font(.subheadline)
                .fontWeight(.bold)

            HStack(spacing: 10) {
                ForEach(insight.relatedMetrics, id: \.self) { metric in
                    Text(metric)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.10))
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var aiSummarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.subheadline)
                    .foregroundColor(.purple)

                Text("AI Summary")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }

            Text(insight.aiSummary)
                .font(.subheadline)
                .foregroundColor(.primary.opacity(0.85))
                .lineSpacing(4)
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.10),
                    Color.blue.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.purple.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct InsightItem: Identifiable {
    let id = UUID()
    let title: String
    let statusText: String
    let statusColor: Color
    let shortSummary: String
    let recommendationPreview: String
    let reasons: [String]
    let observation: String
    let interpretation: String
    let recommendation: String
    let relatedMetrics: [String]
    let aiSummary: String

    static let sampleData: [InsightItem] = [
        InsightItem(
            title: "Recovery Strain",
            statusText: "Needs Attention",
            statusColor: .red,
            shortSummary: "Short sleep and low recovery signals appeared together this week.",
            recommendationPreview: "Prioritize sleep and reduce late-night stimulation.",
            reasons: [
                "Average sleep over 7 days is below 6.5 hours",
                "Average HRV over 7 days is below 35 ms",
                "At least one metric has reached a red-level threshold"
            ],
            observation: "Short sleep and low recovery signals appeared together this week.",
            interpretation: "This pattern suggests that your body may not be recovering well from recent stress and daily demands.",
            recommendation: "Prioritize sleep consistency, reduce late-night stimulation, and consider lighter schedules for the next few days.",
            relatedMetrics: ["Sleep Duration", "HRV"],
            aiSummary: "AI placeholder: Luma detected a possible recovery strain pattern based on lower sleep duration and reduced HRV. This summary can later be generated from real wearable data, journal signals, and recent wellbeing trends."
        ),
        InsightItem(
            title: "Stress Without Movement",
            statusText: "Needs Attention",
            statusColor: .red,
            shortSummary: "Elevated heart rate appeared alongside low movement.",
            recommendationPreview: "This may reflect stress rather than exercise-related activity.",
            reasons: [
                "Average resting heart rate over 7 days is above 95 bpm",
                "Average steps over 7 days is below 4000",
                "High heart rate appeared without enough physical activity"
            ],
            observation: "Elevated resting heart rate appeared at the same time as reduced daily movement.",
            interpretation: "This may suggest stress, fatigue, or poor recovery rather than exercise-driven heart rate elevation.",
            recommendation: "Try a short walk, hydration, and a short breathing break. If the pattern continues, consider checking your health condition more carefully.",
            relatedMetrics: ["Heart Rate", "Steps"],
            aiSummary: "AI placeholder: Luma detected that your heart rate is elevated while movement remains low. This may indicate stress, fatigue, or insufficient recovery rather than exercise-related activity."
        )
    ]
}

#Preview {
    DigitalTwinView()
}
