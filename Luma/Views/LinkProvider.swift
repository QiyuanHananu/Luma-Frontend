//
//  LinkProvider.swift
//  Luma
//
//  Created by Jiaoyang Liu on 26/9/2025.
//


import SwiftUI
import AuthenticationServices

struct AccountLinkView: View {
    var body: some View {
        VStack(spacing: 24) {

            // MARK: Header
            HeaderSection()

            // MARK: Buttons
            VStack(spacing: 14) {
                SignInWithAppleButton(.signIn,
                                      onRequest: { req in
                                          req.requestedScopes = [.fullName, .email]
                                      },
                                      onCompletion: { _ in })
                .signInWithAppleButtonStyle(.black)
                .frame(height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                CenteredSocialButton(title: "Continue with Google",
                                     icon: "globe",
                                     tint: .green) {
                    // TODO: Google sign-in
                }

                CenteredSocialButton(title: "Continue with Email",
                                     icon: "envelope.fill",
                                     tint: .blue) {
                    // TODO: Email sign-in
                }

                CenteredSocialButton(title: "Continue as Guest",
                                     icon: "person.crop.circle.badge.questionmark",
                                     tint: .gray) {
                    // TODO: Guest flow
                }
            }
            .padding(.horizontal, 20)

            // MARK: Terms
            TermsRow()
                .padding(.top, 6)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // 顶部对齐关键
        .padding(.top, 24)
        .background(Color(.systemBackground))
    }
}

// MARK: - Header
private struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 10) {
            // 没有资源时用 SF Symbol 占位
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
                .foregroundStyle(.ultraThinMaterial)
        }
    }
}

// MARK: - Centered social button (与 Apple 按钮同风格，内容居中)
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

// MARK: - Terms
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

#Preview{
    AccountLinkView()
}
