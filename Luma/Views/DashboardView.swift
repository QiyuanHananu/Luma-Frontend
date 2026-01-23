//
//  DashboardView.swift
//  Luma
//
//  Created by Jiaoyang Liu on 24/1/2026.
//


import SwiftUI

struct DashboardView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var showExportView = false


    // TODO: 后续可从 AppSession / AuthViewModel 读
    let username: String = "admin_lainey"
    let loginMethod: String = "Username"

    var body: some View {
        NavigationStack {
            List {

                // MARK: - Account
                Section("Account") {
                    HStack {
                        Text("Logged in as")
                        Spacer()
                        Text(username)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Login method")
                        Spacer()
                        Text(loginMethod)
                            .foregroundColor(.secondary)
                    }
                }

                // MARK: - Data
                Section("Data") {
                    Button {
                        showExportView = true
                    } label: {
                        Label("Export my data", systemImage: "square.and.arrow.up")
                    }


                    Text("User data is currently stored locally on this device.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                // MARK: - Session
                Section("Session") {
                    Button {
                        switchAccount()
                    } label: {
                        Label("Switch account", systemImage: "person.2")
                    }

                    Button(role: .destructive) {
                        logout()
                    } label: {
                        Label("Log out", systemImage: "arrow.backward.circle")
                    }
                }
            }
            .sheet(isPresented: $showExportView) {
                ExportSharingView()
            }

            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func exportData() {
        print("📤 Export data tapped")
        // MVP：先不真正导出
    }

    private func switchAccount() {
        print("🔄 Switch account tapped")
        logout()
    }

    private func logout() {
        print("🚪 Log out tapped")

        // TODO:
        // 1. 清 Keychain token
        // 2. 重置 AppSession
        // 3. 回到 AppEntryView

        // ① 先关掉 dashboard sheet
        dismiss()

        // ② 再在下一个 runloop 改 session
        DispatchQueue.main.async {
            AuthService.logout()
        }
    }
}

#Preview {
    DashboardView()
}

