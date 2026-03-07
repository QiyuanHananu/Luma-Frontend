//
//  PrivacySecurityView.swift
//  Luma
//
// 
//

import SwiftUI
import LocalAuthentication

// MARK: - Privacy Security Data Models
struct SecuritySetting {
    let id = UUID()
    let title: String
    let description: String
    let isEnabled: Bool
    let category: SecurityCategory
    let icon: String
}

struct DataRetentionSetting {
    let id = UUID()
    let dataType: String
    let retentionPeriod: RetentionPeriod
    let description: String
}

struct AuditLogEntry {
    let id = UUID()
    let timestamp: Date
    let action: String
    let user: String
    let ipAddress: String
    let result: AuditResult
}

enum SecurityCategory: String, CaseIterable {
    case authentication = "Authentication"
    case encryption = "Data Encryption"
    case access = "Access Control"
    case audit = "Audit Logs"
    case privacy = "Privacy Protection"
    
    var color: Color {
        switch self {
        case .authentication: return .blue
        case .encryption: return .green
        case .access: return .orange
        case .audit: return .purple
        case .privacy: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .authentication: return "faceid"
        case .encryption: return "lock.shield.fill"
        case .access: return "key.fill"
        case .audit: return "doc.text.magnifyingglass"
        case .privacy: return "eye.slash.fill"
        }
    }
}

enum RetentionPeriod: String, CaseIterable {
    case oneMonth = "1 Month"
    case threeMonths = "3 Months"
    case sixMonths = "6 Months"
    case oneYear = "1 Year"
    case twoYears = "2 Years"
    case forever = "Permanent Storage"
    
    var days: Int? {
        switch self {
        case .oneMonth: return 30
        case .threeMonths: return 90
        case .sixMonths: return 180
        case .oneYear: return 365
        case .twoYears: return 730
        case .forever: return nil
        }
    }
}

enum AuditResult: String {
    case success = "Success"
    case failed = "Failed"
    case blocked = "Blocked"
    
    var color: Color {
        switch self {
        case .success: return .green
        case .failed: return .red
        case .blocked: return .orange
        }
    }
}

// MARK: - Privacy Security Control View
struct PrivacySecurityView: View {
    @State private var selectedTab = 0
    @State private var securitySettings: [SecuritySetting] = []
    @State private var dataRetentionSettings: [DataRetentionSetting] = []
    @State private var auditLogs: [AuditLogEntry] = []
    @State private var biometricEnabled = true
    @State private var autoLockEnabled = true
    @State private var encryptionEnabled = true
    @State private var showBiometricSetup = false
    @State private var showDataDeletionAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Security status overview
            securityOverview
            
            // Tab selector
            tabSelector
            
            TabView(selection: $selectedTab) {
                // Security settings
                securitySettingsView
                    .tag(0)
                
                // Data retention control
                dataRetentionView
                    .tag(1)
                
                // Audit logs
                auditLogView
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .onAppear {
            loadPrivacySecurityData()
        }
        .alert("Delete Data", isPresented: $showDataDeletionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm Delete", role: .destructive) {
                // Execute data deletion
            }
        } message: {
            Text("This operation will permanently delete the selected data and cannot be recovered. Please confirm to continue.")
        }
    }
    
    private var securityOverview: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Security Status")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // HIPAA Compliance Badge
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text("HIPAA Compliant")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // 安全指标
            HStack(spacing: 16) {
                SecurityIndicator(
                    title: "Data Encryption",
                    status: encryptionEnabled ? "Enabled" : "Disabled",
                    color: encryptionEnabled ? .green : .red,
                    icon: "lock.shield.fill"
                )
                
                SecurityIndicator(
                    title: "Biometric Auth",
                    status: biometricEnabled ? "Enabled" : "Disabled",
                    color: biometricEnabled ? .green : .orange,
                    icon: "faceid"
                )
                
                SecurityIndicator(
                    title: "Auto Lock",
                    status: autoLockEnabled ? "Enabled" : "Disabled",
                    color: autoLockEnabled ? .green : .orange,
                    icon: "lock.fill"
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabSelectorButton(title: "Security Settings", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabSelectorButton(title: "Data Retention", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabSelectorButton(title: "Audit Logs", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private var securitySettingsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // 身份验证设置
                authenticationSettings
                
                // 加密设置
                encryptionSettings
                
                // 访问控制设置
                accessControlSettings
                
                // 隐私保护设置
                privacyProtectionSettings
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var dataRetentionView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // 数据保留说明
                dataRetentionInstructions
                
                // 数据保留设置
                ForEach(dataRetentionSettings, id: \.id) { setting in
                    DataRetentionCard(setting: setting) { newPeriod in
                        updateRetentionPeriod(for: setting, to: newPeriod)
                    }
                }
                
                // 数据删除控制
                dataDeleteionControls
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var auditLogView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // 审计日志说明
                auditLogInstructions
                
                // 审计日志列表
                ForEach(auditLogs, id: \.id) { log in
                    AuditLogCard(log: log)
                }
                
                if auditLogs.isEmpty {
                    emptyAuditLogs
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var authenticationSettings: some View {
        SecurityCategoryCard(title: "Authentication", icon: "faceid", color: .blue) {
            VStack(spacing: 12) {
                SecurityToggle(
                    title: "Biometric Login",
                    description: "Use Face ID or Touch ID for quick and secure login",
                    isOn: $biometricEnabled,
                    icon: "faceid"
                )
                
                SecurityToggle(
                    title: "Auto Lock",
                    description: "Automatically lock the app after 5 minutes of inactivity",
                    isOn: $autoLockEnabled,
                    icon: "lock.fill"
                )
                
                Button("Setup Biometric") {
                    showBiometricSetup = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var encryptionSettings: some View {
        SecurityCategoryCard(title: "Data Encryption", icon: "lock.shield.fill", color: .green) {
            VStack(spacing: 12) {
                SecurityToggle(
                    title: "End-to-End Encryption",
                    description: "All data transmission uses AES-256 encryption",
                    isOn: $encryptionEnabled,
                    icon: "lock.shield.fill"
                )
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("Local data is encrypted and stored")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("Cloud backup uses zero-knowledge encryption")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var accessControlSettings: some View {
        SecurityCategoryCard(title: "Access Control", icon: "key.fill", color: .orange) {
            VStack(spacing: 12) {
                HStack {
                    Text("Fine-grained Permission Control")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("Enabled")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Revocable Access Permissions")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("Enabled")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Access Time Limits")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("Enabled")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    private var privacyProtectionSettings: some View {
        SecurityCategoryCard(title: "Privacy Protection", icon: "eye.slash.fill", color: .red) {
            VStack(spacing: 12) {
                HStack {
                    Text("Data Anonymization")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("Automatic")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Minimize Data Collection")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("Enabled")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Third-party Data Sharing")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("Disabled")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private var dataRetentionInstructions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Data Retention Control")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text("You can control how long different types of data are stored. Expired data will be automatically and securely deleted to free up storage space and protect your privacy.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var dataDeleteionControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Deletion Control")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                Button(action: { showDataDeletionAlert = true }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                        
                        Text("Delete All Health Data")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                    .padding(16)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "arrow.down.doc.fill")
                            .foregroundColor(.blue)
                        
                        Text("Export Then Delete")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(16)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var auditLogInstructions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text("Access Audit Logs")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text("Records all access activities to your health data, including access time, user identity, and operation results. Helps you monitor data security.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var emptyAuditLogs: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Audit Records")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Records will appear here when there are access activities")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func loadPrivacySecurityData() {
        // Load data retention settings
        dataRetentionSettings = [
            DataRetentionSetting(
                dataType: "Health Data",
                retentionPeriod: .twoYears,
                description: "Heart rate, sleep, exercise and other physiological data"
            ),
            DataRetentionSetting(
                dataType: "Chat Records",
                retentionPeriod: .sixMonths,
                description: "Conversation history with AI assistant"
            ),
            DataRetentionSetting(
                dataType: "Mood Diary",
                retentionPeriod: .oneYear,
                description: "Mood records and mental health data"
            ),
            DataRetentionSetting(
                dataType: "Usage Logs",
                retentionPeriod: .threeMonths,
                description: "App usage statistics and behavioral data"
            )
        ]
        
        // Load audit logs (mock data)
        auditLogs = [
            AuditLogEntry(
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                action: "View Health Data",
                user: "Dr. Zhang",
                ipAddress: "192.168.1.100",
                result: .success
            ),
            AuditLogEntry(
                timestamp: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(),
                action: "Export Data",
                user: "User",
                ipAddress: "192.168.1.101",
                result: .success
            ),
            AuditLogEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                action: "Attempted Access",
                user: "Unknown User",
                ipAddress: "203.0.113.1",
                result: .blocked
            )
        ]
    }
    
    private func updateRetentionPeriod(for setting: DataRetentionSetting, to period: RetentionPeriod) {
        if let index = dataRetentionSettings.firstIndex(where: { $0.id == setting.id }) {
            dataRetentionSettings[index] = DataRetentionSetting(
                dataType: setting.dataType,
                retentionPeriod: period,
                description: setting.description
            )
        }
    }
}

// MARK: - Supporting Components

struct SecurityIndicator: View {
    let title: String
    let status: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(status)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SecurityCategoryCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct SecurityToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(isOn ? .green : .secondary)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

struct DataRetentionCard: View {
    let setting: DataRetentionSetting
    let onPeriodChange: (RetentionPeriod) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(setting.dataType)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Menu {
                    ForEach(RetentionPeriod.allCases, id: \.self) { period in
                        Button(period.rawValue) {
                            onPeriodChange(period)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(setting.retentionPeriod.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Text(setting.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let days = setting.retentionPeriod.days {
                Text("Data will be automatically deleted after \(days) days")
                    .font(.caption2)
                    .foregroundColor(.orange)
            } else {
                Text("Data will be permanently stored")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct AuditLogCard: View {
    let log: AuditLogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(log.action)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(log.result.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(log.result.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(log.result.color.opacity(0.1))
                    .cornerRadius(6)
            }
            
            HStack {
                Text("User: \(log.user)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatTimestamp(log.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("IP: \(log.ipAddress)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct PrivacySecurityView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacySecurityView()
    }
}
