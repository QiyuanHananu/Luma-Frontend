//
//  LinkProvider.swift
//  Luma
//
//  Created by Jiaoyang Liu on 26/9/2025.
//


import SwiftUI
import AuthenticationServices
import Security

// MARK: - Config
private let APIBaseURL = "http://192.168.1.2:8001" // TODO: 改成你的后端地址

// MARK: - View
struct AccountLinkView: View {
    @EnvironmentObject private var session: AppSession
    @StateObject private var vm = AuthViewModel()

    @State private var showUsernameSheet = false

    var body: some View {
        VStack(spacing: 24) {

            HeaderSection()

            VStack(spacing: 14) {
                // Apple 登录：先留接口（真正接入要把 identityToken 发给后端换你自己的 JWT）
                SignInWithAppleButton(.signIn,
                                      onRequest: { req in
                                          req.requestedScopes = [.fullName, .email]
                                      },
                                      onCompletion: { result in
                                          // TODO: 把 Apple credential 的 identityToken 发给后端换 JWT
                                          // vm.signInWithApple(result)
                                      })
                .signInWithAppleButtonStyle(.black)
                .frame(height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                CenteredSocialButton(title: "Continue with Google",
                                     icon: "globe",
                                     tint: .green) {
                    // TODO: Google sign-in（同理：拿到 Google idToken 发给后端换 JWT）
                }

                CenteredSocialButton(title: "Continue with Username",
                                     icon: "person.fill",
                                     tint: .blue) {
                    showUsernameSheet = true
                }
            }
            .padding(.horizontal, 20)

            TermsRow()
                .padding(.top, 6)

            // 状态展示（方便你调试）
            if vm.isLoading {
                ProgressView("Signing in...")
                    .padding(.top, 8)
            }

            if let err = vm.errorMessage {
                Text(err)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .padding(.horizontal, 20)
            }

            if let me = vm.me {
                Text("✅ Logged in as \(me.username)")
                    .font(.footnote)
                    .padding(.top, 8)
                    .onAppear {
                                session.isLoggedIn = true
                            }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 24)
        .background(Color(.systemBackground))
        .sheet(isPresented: $showUsernameSheet) {
            UserLoginSheet(
                isPresented: $showUsernameSheet,
                onLogin: { username, password in
                    Task { await vm.loginWithUsername(username: username, password: password) }
                }
            )
            .presentationDetents([.medium])
        }
    }
}

// MARK: - Username Login Sheet
private struct UserLoginSheet: View {
    @Binding var isPresented: Bool
    let onLogin: (String, String) -> Void

    @State private var username = ""
    @State private var password = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Account") {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField("Password", text: $password)
                }

                Section {
                    Button("Sign In") {
                        onLogin(username, password)
                    }
                    .disabled(username.isEmpty || password.isEmpty)
                }
            }
            .navigationTitle("Sign in with Username")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { isPresented = false }
                }
            }
        }
    }
}

// MARK: - ViewModel
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var me: MeResponse?

    func loginWithUsername(username: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            // 1) 登录拿 JWT
            let tokens = try await AuthAPI.login(username: username, password: password)

            // 2) 保存 token 到 Keychain（App 重启也还在）
            Keychain.save(tokens.access, for: "luma.jwt.access")
            Keychain.save(tokens.refresh, for: "luma.jwt.refresh")

            // 3) 立刻打 /api/me 验证 token 是否可用
            let meResp = try await AuthAPI.me()
            self.me = meResp
        } catch {
            self.errorMessage = "Login failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - API Layer
enum AuthAPI {
    struct Tokens: Decodable {
        let refresh: String
        let access: String
    }

    static func login(username: String, password: String) async throws -> Tokens {
        let req = LoginRequest(username: username, password: password)

        return try await APIClient.shared.request(
            path: "/api/auth/login/",
            method: "POST",
            body: req,
            requiresAuth: false
        )
    }

    static func me() async throws -> MeResponse {
        return try await APIClient.shared.request(
            path: "/api/me",
            method: "GET",
            requiresAuth: true
        )
    }
}


// MARK: - Keychain helper
enum Keychain {
    static func save(_ value: String, for key: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)

        let add: [String: Any] = query.merging([
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]) { $1 }

        SecItemAdd(add as CFDictionary, nil)
    }

    static func read(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Header / Buttons / Terms (你原来的不动)
private struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer(minLength: 0)
            Image(systemName: "stethoscope.circle.fill")
                .font(.system(size: 56))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .blue)
                .padding(10)
                .background(Circle().fill(Color.blue.opacity(0.16)))
            Spacer(minLength: 0)

            Text("Welcome to Luma")
                .font(.title3).bold()

            Text("Choose how you’d like to sign in")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

private struct CenteredSocialButton: View {
    let title: String
    let icon: String
    let tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer(minLength: 0)
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                Spacer(minLength: 0)
            }
            .frame(height: 48)
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
    }
}

private struct TermsRow: View {
    var body: some View {
        Text("By continuing, you agree to our ")
            .foregroundStyle(.secondary)
            .font(.footnote)
        + Text("Terms").foregroundStyle(.blue).font(.footnote)
        + Text(" and ").foregroundStyle(.secondary).font(.footnote)
        + Text("Privacy Policy").foregroundStyle(.blue).font(.footnote)
    }
}

#Preview {
    let session = AppSession.shared
    session.isLoggedIn = true

    return AccountLinkView()
        .environmentObject(session)
}

