//
//  ProfileView.swift
//  Luma
//
//  Created by Jiaoyang Liu on 26/9/2025.
//


import SwiftUI
import PhotosUI

struct ProfileView: View {
    // Mock user state
    @State private var displayName = "USER"
    @State private var email = "you@example.com"

    // Avatar picking
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?

    // Preferences
    @State private var notificationsOn = true
    @State private var hapticsOn = true
    @State private var useBiometrics = true
    @State private var appearance: Appearance = .system

    // Actions
    var onSignOut: () -> Void = { print("🔓 Sign out tapped") }
    var onDeleteAccount: () -> Void = { print("⚠️ Delete account tapped") }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HeaderSection(displayName: $displayName,
                                  email: $email,
                                  avatarImage: $avatarImage,
                                  avatarItem: $avatarItem)

                    // Account
                    SectionCard {
                        SectionHeader("Account")
                        ProfileRow(title: "Personal Info",
                                   subtitle: "Name, birthday, gender",
                                   icon: "person.text.rectangle",
                                   tint: .blue) {
                            print("➡️ Personal Info")
                        }
                        Divider()
                        ProfileRow(title: "Linked Accounts",
                                   subtitle: "Apple, Google, Email",
                                   icon: "link",
                                   tint: .green) {
                            print("➡️ Linked Accounts")
                        }
                        Divider()
                        ProfileRow(title: "Security",
                                   subtitle: "Password, 2FA, devices",
                                   icon: "lock.shield",
                                   tint: .purple) {
                            print("➡️ Security")
                        }
                    }

                    // Preferences
                    SectionCard {
                        SectionHeader("Preferences")
                        PickerRow(title: "Theme",
                                  icon: "paintbrush",
                                  tint: .orange,
                                  selection: $appearance)
                        Divider()
                        ToggleRow(title: "Notifications",
                                  icon: "bell",
                                  tint: .blue,
                                  isOn: $notificationsOn)
                        Divider()
                        ToggleRow(title: "Haptics",
                                  icon: "waveform.path",
                                  tint: .pink,
                                  isOn: $hapticsOn)
                        Divider()
                        ToggleRow(title: "Use Face ID / Touch ID",
                                  icon: "faceid",
                                  tint: .green,
                                  isOn: $useBiometrics)
                    }

                    // Data & Privacy
                    SectionCard {
                        SectionHeader("Data & Privacy")
                        ProfileRow(title: "Health Data Permissions",
                                   subtitle: "Manage data access",
                                   icon: "heart.text.square",
                                   tint: .red) {
                            print("➡️ Health permissions")
                        }
                        Divider()
                        ProfileRow(title: "Export My Data",
                                   subtitle: "Download a copy",
                                   icon: "square.and.arrow.down",
                                   tint: .teal) {
                            print("➡️ Export data")
                        }
                        Divider()
                        DestructiveRow(title: "Delete Account",
                                       icon: "trash",
                                       action: onDeleteAccount)
                    }

                    // Sign out
                    Button(action: onSignOut) {
                        Text("Sign Out")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .frame(maxWidth: 480)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Profile").font(.headline)
            }
        }
    }
}

// MARK: - Header

private struct HeaderSection: View {
    @Binding var displayName: String
    @Binding var email: String
    @Binding var avatarImage: Image?
    @Binding var avatarItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                if let avatarImage {
                    avatarImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 88, height: 88)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 88, height: 88)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 36, weight: .regular))
                                .foregroundColor(.blue)
                        )
                }

                PhotosPicker(selection: $avatarItem, matching: .images) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(Color.blue))
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
                .offset(x: 32, y: 32)
                .onChange(of: avatarItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let ui = UIImage(data: data) {
                            avatarImage = Image(uiImage: ui)
                        }
                    }
                }
            }

            Text(displayName)
                .font(.title3).bold()

            Text(email)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Reusable rows & containers

private struct SectionCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .cornerRadius(12)
    }
}

private struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .padding(.bottom, 8)
    }
}

private struct IconBadge: View {
    let systemName: String
    let tint: Color
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(tint)
            .frame(width: 28, height: 28)
            .background(tint.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ProfileRow: View {
    let title: String
    var subtitle: String? = nil
    let icon: String
    let tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                IconBadge(systemName: icon, tint: tint)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
    }
}

private struct ToggleRow: View {
    let title: String
    let icon: String
    let tint: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, tint: tint)
            Text(title)
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

private struct PickerRow: View {
    let title: String
    let icon: String
    let tint: Color
    @Binding var selection: Appearance

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, tint: tint)
            Text(title)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(1)      

            Spacer()
            Picker("", selection: $selection) {
                ForEach(Appearance.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
        }
        .padding(.vertical, 8)
    }
}

private struct DestructiveRow: View {
    let title: String
    let icon: String
    var action: () -> Void
    var body: some View {
        Button(role: .destructive, action: action) {
            HStack(spacing: 12) {
                IconBadge(systemName: icon, tint: .red)
                Text(title)
                    .foregroundColor(.red)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
    }
}

// MARK: - Models

enum Appearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var title: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProfileView()
    }
}
