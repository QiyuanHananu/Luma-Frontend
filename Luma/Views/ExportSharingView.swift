//
//  ExportSharingView.swift
//  Luma
//
// 
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Export sharing data models
struct ExportOption {
    let id = UUID()
    let title: String
    let description: String
    let format: ExportFormat
    let icon: String
    let isAvailable: Bool
}

struct SharingOption {
    let id = UUID()
    let title: String
    let description: String
    let recipientType: RecipientType
    let icon: String
    let color: Color
}

struct SharedAccess {
    let id = UUID()
    let recipientName: String
    let recipientType: RecipientType
    let accessLevel: AccessLevel
    let sharedDate: Date
    let expiryDate: Date?
    let isActive: Bool
}

enum ExportFormat: String, CaseIterable {
    case pdf = "PDF"
    case csv = "CSV"
    case json = "JSON"
    case healthKit = "HealthKit"
    
    var fileExtension: String {
        switch self {
        case .pdf: return "pdf"
        case .csv: return "csv"
        case .json: return "json"
        case .healthKit: return "xml"
        }
    }
    
    var mimeType: String {
        switch self {
        case .pdf: return "application/pdf"
        case .csv: return "text/csv"
        case .json: return "application/json"
        case .healthKit: return "application/xml"
        }
    }
}

enum RecipientType: String, CaseIterable {
    case doctor = "Doctor"
    case therapist = "Therapist"
    case family = "Family Member"
    case emergency = "Emergency Contact"
    case employer = "Corporate Health Plan"
    case researcher = "Research Institution"
    
    var color: Color {
        switch self {
        case .doctor: return .blue
        case .therapist: return .purple
        case .family: return .green
        case .emergency: return .red
        case .employer: return .orange
        case .researcher: return .indigo
        }
    }
    
    var icon: String {
        switch self {
        case .doctor: return "stethoscope"
        case .therapist: return "brain.head.profile"
        case .family: return "person.2.fill"
        case .emergency: return "phone.fill"
        case .employer: return "building.2.fill"
        case .researcher: return "graduationcap.fill"
        }
    }
}

enum AccessLevel: String, CaseIterable {
    case full = "Full Access"
    case summary = "Summary Access"
    case specific = "Specific Data"
    case emergency = "Emergency Access"
    
    var description: String {
        switch self {
        case .full: return "Can view all health data and analysis reports"
        case .summary: return "Can only view health summaries and trends"
        case .specific: return "Can only view specified health indicators"
        case .emergency: return "Can view critical health information in emergencies"
        }
    }
    
    var color: Color {
        switch self {
        case .full: return .red
        case .summary: return .orange
        case .specific: return .blue
        case .emergency: return .purple
        }
    }
}

// MARK: - Export sharing view
struct ExportSharingView: View {
    @State private var selectedTab = 0
    @State private var exportOptions: [ExportOption] = []
    @State private var sharingOptions: [SharingOption] = []
    @State private var sharedAccesses: [SharedAccess] = []
    @State private var showExportSheet = false
    @State private var showSharingSheet = false
    @State private var selectedExportOption: ExportOption?
    @State private var selectedSharingOption: SharingOption?
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            tabSelector
            
            TabView(selection: $selectedTab) {
                // Export options
                exportOptionsView
                    .tag(0)
                
                // Share management
                sharingManagementView
                    .tag(1)
                
                // Access records
                accessRecordsView
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .onAppear {
            loadExportSharingData()
        }
        .sheet(isPresented: $showExportSheet) {
            if let option = selectedExportOption {
                ExportConfigurationView(option: option)
            }
        }
        .sheet(isPresented: $showSharingSheet) {
            if let option = selectedSharingOption {
                SharingConfigurationView(option: option)
            }
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabSelectorButton(title: "Export Data", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabSelectorButton(title: "Share Management", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabSelectorButton(title: "Access Records", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private var exportOptionsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Export instructions
                exportInstructions
                
                // Export options list
                ForEach(exportOptions, id: \.id) { option in
                    ExportOptionCard(option: option) {
                        selectedExportOption = option
                        showExportSheet = true
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var sharingManagementView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Sharing instructions
                sharingInstructions
                
                // Sharing options list
                ForEach(sharingOptions, id: \.id) { option in
                    SharingOptionCard(option: option) {
                        selectedSharingOption = option
                        showSharingSheet = true
                    }
                }
                
                // Current sharing status
                if !sharedAccesses.isEmpty {
                    currentSharingStatus
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var accessRecordsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Access records instructions
                accessRecordsInstructions
                
                // Access records list
                ForEach(sharedAccesses, id: \.id) { access in
                    AccessRecordCard(access: access) {
                        // Revoke access permissions
                        revokeAccess(access)
                    }
                }
                
                if sharedAccesses.isEmpty {
                    emptyAccessRecords
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var exportInstructions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "square.and.arrow.up.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Data Export")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text("Export your health data in different formats for backup, analysis, or sharing with medical professionals. All exported data is encrypted to ensure your privacy and security.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var sharingInstructions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Secure Sharing")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text("Securely share your health data with medical professionals, family members, or emergency contacts. You can precisely control what content is shared, when, and access permissions.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // HIPAA compliance notice
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text("HIPAA compliant, data transmission fully encrypted")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var accessRecordsInstructions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text("Access Audit")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text("View who accessed your health data and when. You can revoke anyone's access permissions at any time to ensure data security and control.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var currentSharingStatus: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Sharing Status")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(sharedAccesses.filter { $0.isActive }, id: \.id) { access in
                    ActiveSharingCard(access: access)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var emptyAccessRecords: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Access Records")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("When someone accesses your health data, records will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func loadExportSharingData() {
        // Load export options
        exportOptions = [
            ExportOption(
                title: "Clinical Report (PDF)",
                description: "Complete health report for medical professionals, including charts and analysis",
                format: .pdf,
                icon: "doc.text.fill",
                isAvailable: true
            ),
            ExportOption(
                title: "Raw Data (CSV)",
                description: "Structured data for use with Excel or other analysis tools",
                format: .csv,
                icon: "tablecells.fill",
                isAvailable: true
            ),
            ExportOption(
                title: "API Data (JSON)",
                description: "Machine-readable format for developers and researchers",
                format: .json,
                icon: "curlybraces",
                isAvailable: true
            ),
            ExportOption(
                title: "Apple Health Export",
                description: "Export to Apple Health app or other compatible apps",
                format: .healthKit,
                icon: "heart.fill",
                isAvailable: true
            )
        ]
        
        // Load sharing options
        sharingOptions = [
            SharingOption(
                title: "Medical Professionals",
                description: "Share with your doctor, specialists, or therapists",
                recipientType: .doctor,
                icon: "stethoscope",
                color: .blue
            ),
            SharingOption(
                title: "Therapists",
                description: "Share relevant data with mental health professionals",
                recipientType: .therapist,
                icon: "brain.head.profile",
                color: .purple
            ),
            SharingOption(
                title: "Family Members",
                description: "Share health status and trends with family",
                recipientType: .family,
                icon: "person.2.fill",
                color: .green
            ),
            SharingOption(
                title: "Emergency Contacts",
                description: "Access critical health information in emergencies",
                recipientType: .emergency,
                icon: "phone.fill",
                color: .red
            ),
            SharingOption(
                title: "Corporate Health Plans",
                description: "Share anonymized data with employer health plans",
                recipientType: .employer,
                icon: "building.2.fill",
                color: .orange
            )
        ]
        
        // Load access records (mock data)
        sharedAccesses = [
            SharedAccess(
                recipientName: "Dr. Zhang",
                recipientType: .doctor,
                accessLevel: .full,
                sharedDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                expiryDate: Calendar.current.date(byAdding: .day, value: 23, to: Date()),
                isActive: true
            ),
            SharedAccess(
                recipientName: "Therapist Li",
                recipientType: .therapist,
                accessLevel: .summary,
                sharedDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
                expiryDate: Calendar.current.date(byAdding: .day, value: 16, to: Date()),
                isActive: true
            ),
            SharedAccess(
                recipientName: "Family",
                recipientType: .family,
                accessLevel: .specific,
                sharedDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
                expiryDate: nil,
                isActive: false
            )
        ]
    }
    
    private func revokeAccess(_ access: SharedAccess) {
        // Logic for revoking access permissions
        if let index = sharedAccesses.firstIndex(where: { $0.id == access.id }) {
            sharedAccesses[index] = SharedAccess(
                recipientName: access.recipientName,
                recipientType: access.recipientType,
                accessLevel: access.accessLevel,
                sharedDate: access.sharedDate,
                expiryDate: access.expiryDate,
                isActive: false
            )
        }
    }
}

// MARK: - Supporting components

struct TabSelectorButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .blue : .secondary)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    Rectangle()
                        .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                )
                .overlay(
                    Rectangle()
                        .fill(isSelected ? Color.blue : Color.clear)
                        .frame(height: 2),
                    alignment: .bottom
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExportOptionCard: View {
    let option: ExportOption
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: option.icon)
                    .foregroundColor(.blue)
                    .font(.title2)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(option.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!option.isAvailable)
        .opacity(option.isAvailable ? 1.0 : 0.6)
    }
}

struct SharingOptionCard: View {
    let option: SharingOption
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: option.icon)
                    .foregroundColor(option.color)
                    .font(.title2)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(option.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AccessRecordCard: View {
    let access: SharedAccess
    let onRevoke: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: access.recipientType.icon)
                    .foregroundColor(access.recipientType.color)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(access.recipientName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(access.recipientType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(access.isActive ? "Active" : "Revoked")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(access.isActive ? .green : .red)
                    
                    Text(formatDate(access.sharedDate))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text(access.accessLevel.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(access.accessLevel.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(access.accessLevel.color.opacity(0.1))
                    .cornerRadius(6)
                
                if let expiryDate = access.expiryDate {
                    Text("Expires: \(formatDate(expiryDate))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if access.isActive {
                    Button("Revoke", action: onRevoke)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

struct ActiveSharingCard: View {
    let access: SharedAccess
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(access.recipientType.color)
                .frame(width: 8, height: 8)
            
            Text(access.recipientName)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text("·")
                .foregroundColor(.secondary)
            
            Text(access.accessLevel.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if let expiryDate = access.expiryDate {
                Text("\(daysUntil(expiryDate)) days left")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func daysUntil(_ date: Date) -> Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return max(0, days)
    }
}

// MARK: - Configuration views (placeholders)
struct ExportConfigurationView: View {
    let option: ExportOption
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Export Configuration")
                Text(option.title)
                Spacer()
            }
            .navigationTitle("Export Settings")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SharingConfigurationView: View {
    let option: SharingOption
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Sharing Configuration")
                Text(option.title)
                Spacer()
            }
            .navigationTitle("Sharing Settings")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Preview
struct ExportSharingView_Previews: PreviewProvider {
    static var previews: some View {
        ExportSharingView()
    }
}
