//
//  SettingsView.swift
//  MYPlanner
//
//  Settings tab - API key configuration and app information
//  Matching monochrome design system with orange accent
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("claudeAPIKey") private var apiKey: String = ""
    @State private var isAPIKeyVisible: Bool = false
    @State private var showingSaveAlert: Bool = false

    var body: some View {
        NavigationStack {
            List {
                // API Configuration Section
                apiSection

                // App Info Section
                appInfoSection

                // About Section
                aboutSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("API Key Saved", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your Claude API key has been saved.")
            }
        }
    }

    // MARK: - API Section

    private var apiSection: some View {
        Section {
            VStack(alignment: .leading, spacing: AppSizes.Spacing.medium) {
                Text("Claude API Key")
                    .font(.system(size: AppSizes.FontSize.body))
                    .foregroundColor(AppColors.textSecondary)

                HStack(spacing: AppSizes.Spacing.medium) {
                    if isAPIKeyVisible {
                        TextField("sk-ant-...", text: $apiKey)
                            .font(.system(size: AppSizes.FontSize.body, design: .monospaced))
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    } else {
                        SecureField("sk-ant-...", text: $apiKey)
                            .font(.system(size: AppSizes.FontSize.body, design: .monospaced))
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }

                    Button(action: { isAPIKeyVisible.toggle() }) {
                        Image(systemName: isAPIKeyVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(AppSizes.Padding.medium)
                .background(AppColors.surface)
                .cornerRadius(AppSizes.Radius.medium)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))

            // API Key Status
            HStack(spacing: AppSizes.Spacing.medium) {
                Circle()
                    .fill(apiKey.isEmpty ? AppColors.textTertiary : Color.green)
                    .frame(width: 8, height: 8)

                Text(apiKey.isEmpty ? "API key not configured" : "API key configured")
                    .font(.system(size: AppSizes.FontSize.body))
                    .foregroundColor(apiKey.isEmpty ? AppColors.textTertiary : AppColors.textSecondary)

                Spacer()
            }

            // Get API Key Link
            Link(destination: URL(string: "https://console.anthropic.com/settings/keys")!) {
                HStack {
                    Text("Get API Key")
                        .font(.system(size: AppSizes.FontSize.body))

                    Spacer()

                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: AppSizes.FontSize.body))
                }
                .foregroundColor(AppColors.accent)
            }
        } header: {
            Text("API Configuration")
        } footer: {
            Text("Your API key is stored locally on this device. It is used to generate English expressions from your schedules.")
                .font(.system(size: AppSizes.FontSize.small))
                .foregroundColor(AppColors.textTertiary)
        }
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        Section {
            SettingsRow(icon: "mic.fill", title: "Speech Recognition", value: "iOS Speech Framework")
            SettingsRow(icon: "speaker.wave.2.fill", title: "Text-to-Speech", value: "AVSpeechSynthesizer")
            SettingsRow(icon: "brain", title: "AI Provider", value: "Claude (Anthropic)")
            SettingsRow(icon: "internaldrive", title: "Data Storage", value: "SwiftData (Local)")
        } header: {
            Text("App Features")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            SettingsRow(icon: "info.circle", title: "Version", value: appVersion)
            SettingsRow(icon: "hammer", title: "Build", value: buildNumber)

            Link(destination: URL(string: "https://github.com")!) {
                HStack {
                    Image(systemName: "star")
                        .frame(width: 24)
                        .foregroundColor(AppColors.accent)

                    Text("Rate on App Store")
                        .font(.system(size: AppSizes.FontSize.medium))
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: AppSizes.FontSize.body))
                        .foregroundColor(AppColors.textTertiary)
                }
            }

            Link(destination: URL(string: "mailto:support@myplanner.app")!) {
                HStack {
                    Image(systemName: "envelope")
                        .frame(width: 24)
                        .foregroundColor(AppColors.accent)

                    Text("Send Feedback")
                        .font(.system(size: AppSizes.FontSize.medium))
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: AppSizes.FontSize.body))
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        } header: {
            Text("About")
        } footer: {
            Text("MYPlanner - Practice English with your daily schedules")
                .font(.system(size: AppSizes.FontSize.small))
                .foregroundColor(AppColors.textTertiary)
                .frame(maxWidth: .infinity)
                .padding(.top, AppSizes.Spacing.large)
        }
    }

    // MARK: - App Version Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - Settings Row Component

private struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(AppColors.accent)

            Text(title)
                .font(.system(size: AppSizes.FontSize.medium))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: AppSizes.FontSize.body))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}

#Preview("With API Key") {
    SettingsView()
        .onAppear {
            UserDefaults.standard.set("sk-ant-api03-xxxx", forKey: "claudeAPIKey")
        }
}
