//
//  SettingsView.swift
//  MYPlanner
//
//  Settings tab - API key configuration and app information
//  Matching monochrome design system with orange accent
//

import SwiftUI
import SwiftData
import AVFoundation

struct SettingsView: View {
    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Query private var allExpressions: [Expression]

    private let keychain = KeychainService()
    @State private var ttsService = TTSService()
    @State private var apiKey: String = ""
    @State private var isAPIKeyVisible: Bool = false
    @State private var showingSaveAlert: Bool = false
    @State private var showingRegenerateAlert: Bool = false
    @State private var showingVoiceInstructions: Bool = false
    @State private var regeneratedCount: Int = 0
    @State private var isRegenerating: Bool = false

    // Speech Recognition Engine Settings
    @AppStorage("speechRecognitionEngine") private var selectedEngineRawValue: String = SpeechRecognitionEngineType.apple.rawValue

    private var selectedEngine: SpeechRecognitionEngineType {
        get { SpeechRecognitionEngineType(rawValue: selectedEngineRawValue) ?? .apple }
        set { selectedEngineRawValue = newValue.rawValue }
    }

    var body: some View {
        NavigationStack {
            List {
                // API Configuration Section
                apiSection

                // Voice Settings Section
                voiceSection

                // Speech Recognition Section
                speechRecognitionSection

                // Data Management Section
                dataManagementSection

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
                Text("Your API key has been saved securely.")
            }
            .alert("Accents Regenerated", isPresented: $showingRegenerateAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Updated \(regeneratedCount) expressions with CMU Dictionary accents.")
            }
            .alert("Download Premium Voices", isPresented: $showingVoiceInstructions) {
                Button("Open Settings", role: .none) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text("To download premium voices:\n\n1. Open Settings app\n2. Accessibility\n3. Spoken Content\n4. Voices\n5. English\n6. Tap a voice to download")
            }
            .onAppear {
                apiKey = keychain.retrieveAPIKey() ?? ""
            }
            .onChange(of: apiKey) { _, newValue in
                if newValue.isEmpty {
                    keychain.deleteAPIKey()
                } else {
                    keychain.saveAPIKey(newValue)
                }
            }
        }
    }

    // MARK: - API Section

    private var apiSection: some View {
        Section {
            VStack(alignment: .leading, spacing: AppSizes.Spacing.medium) {
                Text("AIService API Key")
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
            Text("Your API key is stored securely in the iOS Keychain. It is used to generate English expressions from your schedules.")
                .font(.system(size: AppSizes.FontSize.small))
                .foregroundColor(AppColors.textTertiary)
        }
    }

    // MARK: - Voice Section

    private var voiceSection: some View {
        Section {
            // Current Voice
            HStack {
                Image(systemName: "speaker.wave.2.fill")
                    .frame(width: 24)
                    .foregroundColor(AppColors.accent)

                Text("Current Voice")
                    .font(.system(size: AppSizes.FontSize.medium))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text(ttsService.currentVoiceName)
                    .font(.system(size: AppSizes.FontSize.body))
                    .foregroundColor(AppColors.textSecondary)
            }

            // Voice Quality
            HStack {
                Image(systemName: "star.fill")
                    .frame(width: 24)
                    .foregroundColor(AppColors.accent)

                Text("Voice Quality")
                    .font(.system(size: AppSizes.FontSize.medium))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text(voiceQualityLabel)
                    .font(.system(size: AppSizes.FontSize.body))
                    .foregroundColor(voiceQualityColor)
            }

            // Download Premium Voices Button
            Button(action: { showingVoiceInstructions = true }) {
                HStack {
                    Image(systemName: "arrow.down.circle")
                        .frame(width: 24)
                        .foregroundColor(AppColors.accent)

                    Text("Download Premium Voices")
                        .font(.system(size: AppSizes.FontSize.medium))
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    Image(systemName: "info.circle")
                        .font(.system(size: AppSizes.FontSize.body))
                        .foregroundColor(AppColors.textTertiary)
                }
            }

            // Test Voice Button
            Button(action: testVoice) {
                HStack {
                    Image(systemName: "play.circle")
                        .frame(width: 24)
                        .foregroundColor(AppColors.accent)

                    Text("Test Voice")
                        .font(.system(size: AppSizes.FontSize.medium))
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    if ttsService.isSpeaking {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            }

            // Debug: Show available voices (prints to console)
            Button(action: { TTSService.printAllVoices() }) {
                HStack {
                    Image(systemName: "list.bullet")
                        .frame(width: 24)
                        .foregroundColor(AppColors.accent)

                    Text("Print Available Voices (Debug)")
                        .font(.system(size: AppSizes.FontSize.medium))
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()
                }
            }
        } header: {
            Text("Voice Settings")
        } footer: {
            Text("For better voice quality, download Premium or Enhanced voices from iOS Settings. Premium voices sound more natural like Siri.")
                .font(.system(size: AppSizes.FontSize.small))
                .foregroundColor(AppColors.textTertiary)
        }
    }

    // Voice quality label based on current voice
    private var voiceQualityLabel: String {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        if let voice = voices.first(where: { $0.name == ttsService.currentVoiceName }) {
            switch voice.quality {
            case .premium: return "Premium"
            case .enhanced: return "Enhanced"
            default: return "Default"
            }
        }
        return "Default"
    }

    // Voice quality color
    private var voiceQualityColor: Color {
        switch voiceQualityLabel {
        case "Premium": return .green
        case "Enhanced": return .blue
        default: return AppColors.textSecondary
        }
    }

    // Test current voice
    private func testVoice() {
        ttsService.speak("Hello! This is a test of the current voice setting.")
    }

    // MARK: - Speech Recognition Section

    private var speechRecognitionSection: some View {
        Section {
            ForEach(SpeechRecognitionEngineType.allCases) { engine in
                Button(action: { selectedEngineRawValue = engine.rawValue }) {
                    HStack {
                        Image(systemName: engine.iconName)
                            .frame(width: 24)
                            .foregroundColor(AppColors.accent)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(engine.displayName)
                                .font(.system(size: AppSizes.FontSize.medium))
                                .foregroundColor(AppColors.textPrimary)

                            Text(engine.description)
                                .font(.system(size: AppSizes.FontSize.small))
                                .foregroundColor(AppColors.textTertiary)
                        }

                        Spacer()

                        if selectedEngineRawValue == engine.rawValue {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.accent)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Speech Recognition Engine")
        } footer: {
            Text("Apple Speech uses iOS built-in recognition (faster, may use network). Whisper runs completely on-device (more accurate, fully offline).")
                .font(.system(size: AppSizes.FontSize.small))
                .foregroundColor(AppColors.textTertiary)
        }
    }

    // MARK: - Data Management Section

    private var dataManagementSection: some View {
        Section {
            // CMU Dictionary Status
            HStack {
                Image(systemName: "book.closed")
                    .frame(width: 24)
                    .foregroundColor(AppColors.accent)

                Text("CMU Dictionary")
                    .font(.system(size: AppSizes.FontSize.medium))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("\(CMUDictionaryService.shared.wordCount) words")
                    .font(.system(size: AppSizes.FontSize.body))
                    .foregroundColor(AppColors.textSecondary)
            }

            // Expression Count
            HStack {
                Image(systemName: "text.quote")
                    .frame(width: 24)
                    .foregroundColor(AppColors.accent)

                Text("Expressions")
                    .font(.system(size: AppSizes.FontSize.medium))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("\(allExpressions.count)")
                    .font(.system(size: AppSizes.FontSize.body))
                    .foregroundColor(AppColors.textSecondary)
            }

            // Regenerate Accents Button
            Button(action: regenerateAccents) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .frame(width: 24)
                        .foregroundColor(AppColors.accent)

                    Text("Regenerate Accents")
                        .font(.system(size: AppSizes.FontSize.medium))
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    if isRegenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: AppSizes.FontSize.body))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
            .disabled(isRegenerating || allExpressions.isEmpty)
        } header: {
            Text("Data Management")
        } footer: {
            Text("Regenerate accents will update all existing expressions using CMU Dictionary for proper stress marking.")
                .font(.system(size: AppSizes.FontSize.small))
                .foregroundColor(AppColors.textTertiary)
        }
    }

    // MARK: - Regenerate Accents

    private func regenerateAccents() {
        isRegenerating = true
        regeneratedCount = 0

        // Process in background to avoid UI blocking
        Task {
            var count = 0

            for expression in allExpressions {
                let newAccent = AccentFormatter.shared.format(expression.english)

                // Only update if accent changed
                if newAccent != expression.accent {
                    expression.accent = newAccent
                    count += 1
                }
            }

            // Update UI on main thread
            await MainActor.run {
                regeneratedCount = count
                isRegenerating = false
                showingRegenerateAlert = true
                print("[SettingsView] Regenerated \(count) expression accents")
            }
        }
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        Section {
            SettingsRow(icon: "mic.fill", title: "Speech Recognition", value: selectedEngine.displayName)
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
            KeychainService().saveAPIKey("sk-ant-api03-xxxx-preview")
        }
}
