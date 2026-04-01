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
                ForEach(DashboardAlert.sample) { alert in
                    alertCard(alert)
                }
            }

            chartCard(title: "Mood Score (14 days)", showLive: true) {
                Chart(DashboardChartPoint.moodSample) { point in
                    LineMark(x: .value("Day", point.label), y: .value("Value", point.value))
                        .foregroundStyle(.blue)
                    PointMark(x: .value("Day", point.label), y: .value("Value", point.value))
                        .foregroundStyle(.blue)
                }
                .frame(height: 170)
            }

            chartCard(title: "Sleep Duration (7 days)", showLive: true) {
                Chart(DashboardChartPoint.sleepSample) { point in
                    BarMark(x: .value("Day", point.label), y: .value("Value", point.value))
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(height: 170)
            }

            chartCard(title: "Recovery Level (7 days)", showLive: true) {
                Chart(DashboardChartPoint.recoverySample) { point in
                    LineMark(x: .value("Day", point.label), y: .value("Value", point.value))
                        .foregroundStyle(.green)
                    PointMark(x: .value("Day", point.label), y: .value("Value", point.value))
                        .foregroundStyle(.green)
                }
                .frame(height: 170)
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
            Text("WELLBEING SNAPSHOT")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("72")
                    .font(.system(size: 42, weight: .bold))
                Text("/ 100")
                    .foregroundColor(.secondary)
            }

            Text("Stable and balanced")
                .font(.subheadline)

            HStack(spacing: 8) {
                Text("Balanced")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.purple.opacity(0.12)))

                Text("• Stable Routine")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.blue.opacity(0.10))
        )
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
