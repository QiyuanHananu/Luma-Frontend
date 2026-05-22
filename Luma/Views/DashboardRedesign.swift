//
//  DashboardRedesign.swift
//  Luma
//
//  Created by flora on 2026/4/2.
//

import SwiftUI
import Charts



struct DashboardRedesignView: View {
    enum DashboardTab: String, CaseIterable {
        case overview = "Overview"
        case records = "Records & Reports"
    }

    enum DemoReportType: String, CaseIterable, Identifiable {
        case wellbeing
        case clinical
        case trend

        var id: String { rawValue }

        var title: String {
            switch self {
            case .wellbeing: return "Wellbeing Summary Report"
            case .clinical: return "Clinical Snapshot Report"
            case .trend: return "Trend Analysis Report"
            }
        }

        var description: String {
            switch self {
            case .wellbeing: return "Overview of your recent wellbeing and insights"
            case .clinical: return "Structured summary for doctor consultation"
            case .trend: return "Detailed trend interpretation across key signals"
            }
        }

        var icon: String {
            switch self {
            case .wellbeing: return "waveform.path.ecg"
            case .clinical: return "doc.text"
            case .trend: return "chart.line.uptrend.xyaxis"
            }
        }

        var color: Color {
            switch self {
            case .wellbeing: return .blue
            case .clinical: return .purple
            case .trend: return .green
            }
        }
    }

    enum ReportRangeOption: String, CaseIterable, Identifiable {
        case last7Days = "Last 7 days"
        case last14Days = "Last 14 days"
        case last30Days = "Last 30 days"

        var id: String { rawValue }
    }

    @State private var selectedTab: DashboardTab = .overview
    @State private var showUploadSheet = false
    @State private var selectedFile: DashboardRecordItem?

    @State private var selectedReportType: DemoReportType?
    @State private var pendingReportType: DemoReportType?
    @State private var showRangeSheet = false
    @State private var selectedRange: ReportRangeOption = .last14Days
    @State private var showGeneratingOverlay = false
    @StateObject private var proactiveViewModel = DashboardProactiveViewModel()
    @StateObject private var healthDashboardViewModel = DashboardHealthViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Dashboard")
                            .font(.largeTitle.bold())
                            .padding(.top, 8)

                        tabBar

                        if selectedTab == .overview {
                            overviewContent
                        } else {
                            recordsContent
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .background(Color(.systemGroupedBackground))
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showUploadSheet) {
                    UploadRecordDemoSheet()
                }
                .sheet(item: $selectedFile) { item in
                    SimpleFilePreviewSheet(item: item)
                }
                .sheet(isPresented: $showRangeSheet) {
                    ReportRangeSelectionSheet(selectedRange: $selectedRange) {
                        showRangeSheet = false
                        startGeneratingDemoReport()
                    }
                }
                .fullScreenCover(item: $selectedReportType) { reportType in
                    DemoReportDetailPage(reportType: reportType, selectedRange: selectedRange)
                }
                .task {
                    await proactiveViewModel.loadProactiveTracking()
                    healthDashboardViewModel.loadHealthDashboard()
                }
                .onChange(of: selectedTab) { _, newValue in
                    if newValue == .overview {
                        Task {
                            await proactiveViewModel.loadProactiveTracking()
                        }
                        healthDashboardViewModel.loadHealthDashboard()
                    }
                }

                if showGeneratingOverlay {
                    generatingOverlay
                }
            }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(DashboardTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(selectedTab == tab ? .blue : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedTab == tab ? Color.white : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var overviewContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            snapshotCard

            Text("Proactive Tracking")
                .font(.title3.weight(.semibold))

            VStack(spacing: 12) {
                if proactiveViewModel.isLoading {
                    ProgressView("Loading proactive insights...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                } else if let errorMessage = proactiveViewModel.errorMessage {
                    alertCard(
                        DashboardAlert(
                            message: "Unable to load AI proactive insight: \(errorMessage)",
                            time: "System"
                        )
                    )
                } else {
                    ForEach(proactiveViewModel.alerts) { alert in
                        alertCard(alert)
                    }
                }
            }

            chartCard(title: "Heart Rate (latest readings)", showLive: healthDashboardViewModel.hasHeartRateData) {
                if healthDashboardViewModel.heartRatePoints.isEmpty {
                    dashboardEmptyChartText("No heart-rate data available yet.")
                } else {
                    Chart(healthDashboardViewModel.heartRatePoints) { point in
                        BarMark(x: .value("Time", point.label), y: .value("BPM", point.value))
                            .foregroundStyle(.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .frame(height: 170)
                }
            }

            chartCard(title: "Sleep Duration (7 days)", showLive: healthDashboardViewModel.hasSleepData) {
                if healthDashboardViewModel.sleepPoints.isEmpty {
                    dashboardEmptyChartText("No sleep data available yet.")
                } else {
                    Chart(healthDashboardViewModel.sleepPoints) { point in
                        BarMark(x: .value("Day", point.label), y: .value("Hours", point.value))
                            .foregroundStyle(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .frame(height: 170)
                }
            }

            chartCard(title: "Recovery Level (HRV)", showLive: healthDashboardViewModel.hasRecoveryData) {
                if healthDashboardViewModel.recoveryPoints.isEmpty {
                    dashboardEmptyChartText("No recovery data available yet.")
                } else {
                    Chart(healthDashboardViewModel.recoveryPoints) { point in
                        BarMark(x: .value("Time", point.label), y: .value("HRV", point.value))
                            .foregroundStyle(.green)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .frame(height: 170)
                }
            }
        }
    }

    private var recordsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Medical Records")
                    .font(.title3.weight(.semibold))

                Spacer()

                Button {
                    showUploadSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Upload")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.blue))
                }
                .buttonStyle(.plain)
            }

            Text("March 2026")
                .font(.headline)

            VStack(alignment: .leading, spacing: 14) {
                Text("Mar 10, 2026")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)

                recordCard(DashboardRecordItem.sample[0])
                recordCard(DashboardRecordItem.sample[1])
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
            )

            VStack(alignment: .leading, spacing: 14) {
                Text("Mar 8, 2026")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)

                recordCard(DashboardRecordItem.sample[2])
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
            )

            Text("Reports")
                .font(.title3.weight(.semibold))
                .padding(.top, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(DemoReportType.allCases) { type in
                        reportCard(type: type)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }

    private var snapshotCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("WELLBEING SNAPSHOT")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)

                Spacer()

                Text(healthDashboardViewModel.sourceLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.blue.opacity(0.10)))
            }

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(healthDashboardViewModel.scoreText)
                    .font(.system(size: 42, weight: .bold))
                Text("/ 100")
                    .foregroundColor(.secondary)
            }

            Text(healthDashboardViewModel.statusTitle)
                .font(.subheadline)

            HStack(spacing: 8) {
                Text(healthDashboardViewModel.levelLabel)
                    .font(.caption.weight(.medium))
                    .foregroundColor(healthDashboardViewModel.statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(healthDashboardViewModel.statusColor.opacity(0.12)))

                Text("• \(healthDashboardViewModel.shortReason)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(healthDashboardViewModel.statusColor.opacity(0.10))
        )
        .task {
            healthDashboardViewModel.loadHealthDashboard()
        }
    }

    private func alertCard(_ alert: DashboardAlert) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 24, height: 24)

                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.blue)
                }

                Text(alert.message)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("• \(alert.time)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 34)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.blue.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.blue.opacity(0.12), lineWidth: 1)
        )
    }

    private func chartCard<Content: View>(
        title: String,
        showLive: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))

                Spacer()

                if showLive {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 7, height: 7)
                        Text("Live Signal")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.green)
                    }
                }
            }

            content()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }

    private func dashboardEmptyChartText(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 170)
            .multilineTextAlignment(.center)
    }

    private func recordCard(_ item: DashboardRecordItem) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "doc.text")
                .foregroundColor(.secondary)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.weight(.medium))

                Text(item.type)
                    .font(.caption)
                    .foregroundColor(.blue)

                Text("Record date: \(item.recordDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Uploaded: \(item.uploadDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("View") {
                selectedFile = item
            }
            .font(.caption.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
            )
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }

    private func reportCard(type: DemoReportType) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(type.color.opacity(0.12))
                    .frame(width: 30, height: 30)

                Image(systemName: type.icon)
                    .foregroundColor(type.color)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(type.title)
                    .font(.headline)

                Text(type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button("View Report") {
                pendingReportType = type
                showRangeSheet = true
            }
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.separator), lineWidth: 1)
            )
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(width: 180, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var generatingOverlay: some View {
        ZStack {
            Color.black.opacity(0.22)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                ProgressView()
                    .scaleEffect(1.25)
                Text("Generating...")
                    .font(.headline)
                Text("Preparing your report")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(.systemBackground))
            )
        }
    }

    private func startGeneratingDemoReport() {
        guard let pendingReportType else { return }
        showGeneratingOverlay = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showGeneratingOverlay = false
            selectedReportType = pendingReportType
            self.pendingReportType = nil
        }
    }
}

private struct UploadRecordDemoSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var recordTitle = ""
    @State private var recordType = "Consultation"
    @State private var recordDate = Date()
    @State private var selectedTag = "Medical"
    @State private var attachedFileName = ""
    @State private var notes = ""

    private let typeOptions = ["Consultation", "Lab Test", "Imaging", "Prescription", "Other"]
    private let tagOptions = ["Medical", "Lab", "Cardiology", "Mental Health", "General"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Upload Record") {
                    TextField("Record title", text: $recordTitle)

                    Picker("Record type", selection: $recordType) {
                        ForEach(typeOptions, id: \.self) { option in
                            Text(option)
                        }
                    }

                    Picker("Tag", selection: $selectedTag) {
                        ForEach(tagOptions, id: \.self) { tag in
                            Text(tag)
                        }
                    }

                    DatePicker("Record date", selection: $recordDate, displayedComponents: .date)

                    TextField("Attached file name", text: $attachedFileName)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section {
                    Text("This demo sheet matches the Figma behavior: upload requires title, tag, and record date so records can be organised on the real timeline rather than upload time.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Upload Medical Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { dismiss() }
                        .disabled(recordTitle.isEmpty || attachedFileName.isEmpty)
                }
            }
        }
    }
}

private struct ReportRangeSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedRange: DashboardRedesignView.ReportRangeOption
    let onGenerate: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Select Time Period") {
                    ForEach(DashboardRedesignView.ReportRangeOption.allCases) { option in
                        Button {
                            selectedRange = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedRange == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Select Time Period")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Generate") {
                        dismiss()
                        onGenerate()
                    }
                }
            }
        }
    }
}

private struct DemoReportDetailPage: View {
    let reportType: DashboardRedesignView.DemoReportType
    let selectedRange: DashboardRedesignView.ReportRangeOption
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: reportType.icon)
                            .foregroundColor(reportType.color)
                        Text(reportType.title)
                            .font(.title2.bold())
                    }

                    Text(selectedRange.rawValue)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.blue.opacity(0.10)))

                    switch reportType {
                    case .wellbeing:
                        wellbeingDemo
                    case .clinical:
                        clinicalDemo
                    case .trend:
                        trendDemo
                    }
                }
                .padding(16)
            }
            .navigationTitle("Report Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var wellbeingDemo: some View {
        VStack(alignment: .leading, spacing: 14) {
            reportSection(title: "CURRENT STATUS") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("72 / 100")
                        .font(.system(size: 34, weight: .bold))
                    Text("Stable and balanced")
                    Text("Mood improved gradually while sleep and recovery remained consistent.")
                        .foregroundColor(.secondary)
                }
            }

            reportSection(title: "INSIGHTS") {
                VStack(alignment: .leading, spacing: 8) {
                    bullet("Mood has gradually improved over the selected period.")
                    bullet("Daily routine remained stable.")
                    bullet("Sleep and recovery patterns support overall balance.")
                }
            }

            reportSection(title: "RECOMMENDATION") {
                Text("Continue the current sleep schedule and preserve short recovery breaks during the workday.")
            }
        }
    }

    private var clinicalDemo: some View {
        VStack(alignment: .leading, spacing: 14) {
            reportSection(title: "CLINICAL SUMMARY") {
                Text("No acute concern detected. Mild HRV fluctuation and one interrupted sleep event were observed, but recovery remained stable.")
            }

            reportSection(title: "RECENT SIGNALS") {
                VStack(alignment: .leading, spacing: 8) {
                    bullet("HRV slightly below weekly baseline on one afternoon.")
                    bullet("REM disruption detected on Mar 18.")
                    bullet("Recovery signal returned to expected range within 24 hours.")
                }
            }

            reportSection(title: "SUPPORTING RECORDS") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Blood Test Report")
                    Text("• ECG Result")
                    Text("• Doctor Notes")
                }
                .foregroundColor(.secondary)
            }
        }
    }

    private var trendDemo: some View {
        VStack(alignment: .leading, spacing: 14) {
            reportSection(title: "TREND INTERPRETATION") {
                Text("Across the selected period, mood score trends upward, sleep duration stays stable, and recovery remains positive with small fluctuations.")
            }

            reportSection(title: "KEY PATTERNS") {
                VStack(alignment: .leading, spacing: 8) {
                    bullet("Mood score improved after stable sleep resumed.")
                    bullet("Sleep duration stayed close to 7–7.5 hours.")
                    bullet("Recovery remained resilient despite short-term stress spikes.")
                }
            }

            reportSection(title: "SUMMARY") {
                Text("The combined trend suggests the user is maintaining a supportive routine and recovering effectively from normal work-related pressure.")
            }
        }
    }

    private func reportSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(reportType.color)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            Text(text)
        }
    }
}

private struct DashboardAlert: Identifiable {
    let id = UUID()
    let message: String
    let time: String

    static let sample: [DashboardAlert] = [
        DashboardAlert(
            message: "Your HRV is 10% lower than your Tuesday average. We predict a dip in focus by 3:00 PM. Suggesting a 10-minute walk now to stabilize.",
            time: "2026-03-24 14:30:00"
        ),
        DashboardAlert(
            message: "Sleep quality dropped last night. Your REM cycles were interrupted. Consider reducing screen time 1 hour before bed tonight.",
            time: "2026-03-18 08:15:00"
        ),
        DashboardAlert(
            message: "Your stress markers are elevated compared to your weekly baseline. We recommend a brief meditation session.",
            time: "2026-03-15 16:45:00"
        )
    ]
}

private struct DashboardChartPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double

    static let moodSample: [DashboardChartPoint] = [
        .init(label: "Mar 6", value: 68),
        .init(label: "Mar 7", value: 65),
        .init(label: "Mar 8", value: 70),
        .init(label: "Mar 9", value: 67),
        .init(label: "Mar 10", value: 69),
        .init(label: "Mar 11", value: 71),
        .init(label: "Mar 12", value: 73),
        .init(label: "Mar 13", value: 70),
        .init(label: "Mar 14", value: 72),
        .init(label: "Mar 15", value: 74),
        .init(label: "Mar 16", value: 71),
        .init(label: "Mar 17", value: 73),
        .init(label: "Mar 18", value: 72),
        .init(label: "Mar 19", value: 72)
    ]

    static let sleepSample: [DashboardChartPoint] = [
        .init(label: "Mar 13", value: 7.2),
        .init(label: "Mar 14", value: 6.8),
        .init(label: "Mar 15", value: 7.5),
        .init(label: "Mar 16", value: 7.0),
        .init(label: "Mar 17", value: 7.3),
        .init(label: "Mar 18", value: 7.1),
        .init(label: "Mar 19", value: 7.4)
    ]

    static let recoverySample: [DashboardChartPoint] = [
        .init(label: "Mar 13", value: 75),
        .init(label: "Mar 14", value: 72),
        .init(label: "Mar 15", value: 78),
        .init(label: "Mar 16", value: 76),
        .init(label: "Mar 17", value: 79),
        .init(label: "Mar 18", value: 77),
        .init(label: "Mar 19", value: 80)
    ]
}

private struct DashboardRecordItem: Identifiable {
    let id = UUID()
    let title: String
    let type: String
    let recordDate: String
    let uploadDate: String
    let fileName: String

    static let sample: [DashboardRecordItem] = [
        DashboardRecordItem(
            title: "Blood Test Report",
            type: "Lab Test",
            recordDate: "Mar 10, 2026",
            uploadDate: "Mar 15, 2026",
            fileName: "Blood Test Report.pdf"
        ),
        DashboardRecordItem(
            title: "ECG Result",
            type: "Imaging",
            recordDate: "Mar 10, 2026",
            uploadDate: "Mar 15, 2026",
            fileName: "ECG Result.pdf"
        ),
        DashboardRecordItem(
            title: "Doctor Notes",
            type: "Consultation",
            recordDate: "Mar 8, 2026",
            uploadDate: "Mar 9, 2026",
            fileName: "Doctor Notes.png"
        )
    ]
}

private struct SimpleFilePreviewSheet: View {
    let item: DashboardRecordItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(height: 280)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: item.fileName.hasSuffix(".pdf") ? "doc.richtext" : "photo")
                                .font(.system(size: 36))
                                .foregroundColor(.blue)

                            Text(item.fileName)
                                .font(.headline)

                            Text("Preview placeholder")
                                .foregroundColor(.secondary)
                        }
                    )

                Button("Done") {
                    dismiss()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.blue))
                .foregroundColor(.white)

                Spacer()
            }
            .padding()
            .navigationTitle("File Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    DashboardRedesignView()
}

@MainActor
private final class DashboardProactiveViewModel: ObservableObject {
    @Published var alerts: [DashboardAlert] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private struct ProactiveTrackingResponse: Decodable {
        let items: [ProactiveTrackingDTO]
    }

    private struct ProactiveTrackingDTO: Decodable {
        let id: String?
        let title: String?
        let message: String?
    }

    func loadProactiveTracking() async {
        print("🌐 Loading proactive tracking from: /api/proactive/tracking/?limit=3")
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let decoded: ProactiveTrackingResponse = try await APIClient.shared.request(
                path: "/api/proactive/tracking/?limit=3",
                method: "GET",
                body: Optional<Int>.none,
                requiresAuth: true
            )
            let mappedAlerts = decoded.items.map { dto in
                DashboardAlert(
                    message: makeAlertMessage(from: dto),
                    time: "Generated by AI"
                )
            }

            if mappedAlerts.isEmpty {
                alerts = [
                    DashboardAlert(
                        message: "No proactive insight available yet. Continue chatting with Luma to generate one.",
                        time: "Generated by AI"
                    )
                ]
            } else {
                alerts = mappedAlerts
            }
        } catch {
            print("❌ Failed to load proactive tracking:", error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }

    private func makeAlertMessage(from dto: ProactiveTrackingDTO) -> String {
        var components: [String] = []

        if let title = dto.title, !title.isEmpty {
            components.append(title)
        }

        if let message = dto.message, !message.isEmpty {
            components.append(message)
        }

        return components.joined(separator: "\n")
    }
}

// Supporting types for HealthKit-driven dashboard and AI assessment
private struct DashboardHealthAssessmentRequest: Encodable {
    let heartRate: Double?
    let hrv: Double?
    let sleepHours: Double?

    enum CodingKeys: String, CodingKey {
        case heartRate = "heart_rate"
        case hrv
        case sleepHours = "sleep_hours"
    }
}

private struct DashboardHealthAssessmentResponse: Decodable {
    let overallStatus: String
    let score: Int
    let summary: String

    enum CodingKeys: String, CodingKey {
        case overallStatus = "overall_status"
        case score
        case summary
    }
}

private struct DashboardHealthChartPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

@MainActor
private final class DashboardHealthViewModel: ObservableObject {
    @Published var score: Int?
    @Published var status: String = "unknown"
    @Published var summary: String = "Connect Apple Watch data to generate a wellbeing score."
    @Published var heartRatePoints: [DashboardHealthChartPoint] = []
    @Published var sleepPoints: [DashboardHealthChartPoint] = []
    @Published var recoveryPoints: [DashboardHealthChartPoint] = []

    private var isLoading = false

    var hasHeartRateData: Bool { !heartRatePoints.isEmpty }
    var hasSleepData: Bool { !sleepPoints.isEmpty }
    var hasRecoveryData: Bool { !recoveryPoints.isEmpty }

    var scoreText: String {
        guard let score else { return "--" }
        return String(score)
    }

    var levelLabel: String {
        switch status {
        case "critical": return "Critical"
        case "warning": return "Warning"
        case "normal": return "Normal"
        default: return "No Data"
        }
    }

    var statusTitle: String {
        switch status {
        case "critical": return "Needs attention"
        case "warning": return "Some signals need a check-in"
        case "normal": return "Stable and balanced"
        default: return "Waiting for health signals"
        }
    }

    var statusColor: Color {
        switch status {
        case "critical": return .red
        case "warning": return .orange
        case "normal": return .green
        default: return .blue
        }
    }

    var shortReason: String {
        if summary.isEmpty { return "Generated by AI assessment" }
        return summary
    }

    var sourceLabel: String {
        score == nil ? "Apple Watch" : "AI scored"
    }

    func loadHealthDashboard() {
        guard !isLoading else { return }
        isLoading = true

        HealthKitManager.shared.fetchLatestHeartRate { [weak self] heartReading in
            guard let self else { return }
            HealthKitManager.shared.fetchAverageHRVLast24Hours { hrvValue in
                HealthKitManager.shared.fetchSleepHoursFromLastNight { sleepHours in
                    DispatchQueue.main.async {
                        self.buildChartData(
                            latestHeartRate: heartReading?.bpm,
                            latestHRV: hrvValue,
                            latestSleepHours: sleepHours
                        )

                        Task {
                            await self.loadAIAssessment(
                                heartRate: heartReading?.bpm,
                                hrv: hrvValue,
                                sleepHours: sleepHours
                            )
                        }
                    }
                }
            }
        }
    }

    private func buildChartData(latestHeartRate: Double?, latestHRV: Double?, latestSleepHours: Double?) {
        loadHeartRateTrend()

        HealthKitManager.shared.fetchSleepTrendReadings(range: .week) { [weak self] readings in
            DispatchQueue.main.async {
                self?.sleepPoints = readings.map {
                    DashboardHealthChartPoint(label: $0.label, value: $0.hours)
                }
            }
        }

        loadHRVTrend()
    }
    
    private func loadHeartRateTrend() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .hour, value: -12, to: endDate) ?? endDate.addingTimeInterval(-12 * 60 * 60)

        HealthKitManager.shared.fetchHeartRateReadings(from: startDate, to: endDate) { [weak self] readings in
            DispatchQueue.main.async {
                guard let self else { return }
                self.heartRatePoints = self.compactHeartRateReadings(readings, targetCount: 6)
            }
        }
    }

    private func compactHeartRateReadings(
        _ readings: [HealthKitManager.HeartRateTrendReading],
        targetCount: Int
    ) -> [DashboardHealthChartPoint] {
        guard !readings.isEmpty else { return [] }

        guard readings.count > targetCount else {
            return readings.map {
                DashboardHealthChartPoint(label: chartTimeLabel(for: $0.endDate), value: $0.bpm)
            }
        }

        let chunkSize = Double(readings.count) / Double(targetCount)

        return (0..<targetCount).compactMap { index in
            let start = Int(Double(index) * chunkSize)
            let end = min(Int(Double(index + 1) * chunkSize), readings.count)
            let chunk = Array(readings[start..<max(start + 1, end)])

            guard let representative = chunk.last else { return nil }

            let average = chunk.map(\.bpm).reduce(0, +) / Double(chunk.count)

            return DashboardHealthChartPoint(
                label: chartTimeLabel(for: representative.endDate),
                value: average
            )
        }
    }

    private func chartTimeLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "ha"
        return formatter.string(from: date)
    }

    private func makeRecentPoints(from currentValue: Double, labels: [String], step: Double) -> [DashboardHealthChartPoint] {
        labels.enumerated().map { index, label in
            let distance = Double(labels.count - index - 1)
            let adjusted = max(0, currentValue - distance * step + Double(index % 2) * step * 0.45)
            return DashboardHealthChartPoint(label: label, value: adjusted)
        }
    }

    private func loadAIAssessment(heartRate: Double?, hrv: Double?, sleepHours: Double?) async {
        defer { isLoading = false }

        do {
            let response: DashboardHealthAssessmentResponse = try await APIClient.shared.request(
                path: "/api/health/assess/",
                method: "POST",
                body: DashboardHealthAssessmentRequest(
                    heartRate: heartRate,
                    hrv: hrv,
                    sleepHours: sleepHours
                ),
                requiresAuth: false
            )

            score = response.score
            status = response.overallStatus
            summary = response.summary
        } catch {
            print("❌ Failed to load dashboard AI health assessment:", error.localizedDescription)
            score = fallbackScore(heartRate: heartRate, hrv: hrv, sleepHours: sleepHours)
            status = fallbackStatus(score: score)
            summary = "Generated from available Apple Watch signals."
        }
    }

    private func fallbackScore(heartRate: Double?, hrv: Double?, sleepHours: Double?) -> Int? {
        var scores: [Int] = []

        if let sleepHours {
            if sleepHours >= 7 { scores.append(90) }
            else if sleepHours >= 6 { scores.append(75) }
            else if sleepHours >= 4 { scores.append(60) }
            else { scores.append(35) }
        }

        if let heartRate {
            if heartRate >= 50 && heartRate <= 100 { scores.append(90) }
            else if heartRate <= 120 { scores.append(65) }
            else { scores.append(35) }
        }

        if let hrv {
            if hrv >= 35 { scores.append(90) }
            else if hrv >= 20 { scores.append(65) }
            else { scores.append(35) }
        }

        guard !scores.isEmpty else { return nil }
        return scores.reduce(0, +) / scores.count
    }

    private func fallbackStatus(score: Int?) -> String {
        guard let score else { return "unknown" }
        if score < 50 { return "critical" }
        if score < 75 { return "warning" }
        return "normal"
    }

    private func loadHRVTrend() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .hour, value: -24, to: endDate) ?? endDate.addingTimeInterval(-24 * 60 * 60)

        HealthKitManager.shared.fetchHRVReadings(from: startDate, to: endDate) { [weak self] readings in
            DispatchQueue.main.async {
                guard let self else { return }
                self.recoveryPoints = self.compactHRVReadings(readings, targetCount: 6)
            }
        }
    }

    private func compactHRVReadings(
        _ readings: [HealthKitManager.HRVReading],
        targetCount: Int
    ) -> [DashboardHealthChartPoint] {
        guard !readings.isEmpty else { return [] }

        guard readings.count > targetCount else {
            return readings.map {
                DashboardHealthChartPoint(label: chartTimeLabel(for: $0.endDate), value: $0.sdnnMs)
            }
        }

        let chunkSize = Double(readings.count) / Double(targetCount)

        return (0..<targetCount).compactMap { index in
            let start = Int(Double(index) * chunkSize)
            let end = min(Int(Double(index + 1) * chunkSize), readings.count)
            let chunk = Array(readings[start..<max(start + 1, end)])

            guard let representative = chunk.last else { return nil }

            let average = chunk.map(\.sdnnMs).reduce(0, +) / Double(chunk.count)

            return DashboardHealthChartPoint(
                label: chartTimeLabel(for: representative.endDate),
                value: average
            )
        }
    }
}
