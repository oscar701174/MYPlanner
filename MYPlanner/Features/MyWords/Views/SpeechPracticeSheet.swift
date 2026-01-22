//
//  SpeechPracticeSheet.swift
//  MYPlanner
//
//  발음 연습 시트
//  - 녹음 상태 표시
//  - 발음 결과 표시
//  - 권한 요청 처리
//

import SwiftUI
import SwiftData

struct SpeechPracticeSheet: View {
    let expression: Expression
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: SpeechPracticeViewModel = SpeechPracticeViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.state {
                case .idle:
                    idleView

                case .recording:
                    recordingView

                case .evaluating:
                    evaluatingView

                case .result:
                    if let score = viewModel.score {
                        PracticeResultView(
                            score: score,
                            originalText: viewModel.originalText,
                            recognizedText: viewModel.recognizedText,
                            onRetry: {
                                Task {
                                    viewModel.reset()
                                    await viewModel.startPractice(for: expression.english)
                                }
                            },
                            onDismiss: {
                                dismiss()
                            }
                        )
                    }

                case .error:
                    errorView
                }
            }
            .navigationTitle("Practice Speaking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.stopPractice()
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Idle View

    private var idleView: some View {
        VStack(spacing: AppSizes.Spacing.xlarge) {
            Spacer()

            // Expression to practice
            VStack(spacing: AppSizes.Spacing.medium) {
                Text("Say this expression:")
                    .font(.system(size: AppSizes.FontSize.medium))
                    .foregroundColor(AppColors.textSecondary)

                Text(expression.english)
                    .font(.system(size: AppSizes.FontSize.xlarge, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Mic icon
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColors.accent)

            Spacer()

            // Start button
            Button(action: {
                Task {
                    await viewModel.startPractice(for: expression.english)
                }
            }) {
                HStack {
                    Image(systemName: "mic.fill")
                    Text("Start Recording")
                }
                .font(.system(size: AppSizes.FontSize.medium, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSizes.Padding.vertical)
                .background(AppColors.accent)
                .cornerRadius(AppSizes.Radius.medium)
            }
            .padding(.horizontal, AppSizes.Padding.horizontal)
            .padding(.bottom, AppSizes.Padding.vertical)
        }
    }

    // MARK: - Recording View

    private var recordingView: some View {
        VStack(spacing: AppSizes.Spacing.xlarge) {
            Spacer()

            // Expression being practiced
            VStack(spacing: AppSizes.Spacing.medium) {
                Text("Listening...")
                    .font(.system(size: AppSizes.FontSize.medium))
                    .foregroundColor(AppColors.textSecondary)

                Text(expression.english)
                    .font(.system(size: AppSizes.FontSize.large, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Recording indicator
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.2))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(AppColors.accent.opacity(0.4))
                    .frame(width: 90, height: 90)

                Image(systemName: "waveform")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.accent)
                    .symbolEffect(.variableColor.iterative.reversing)
            }

            // Recognized text (live update)
            VStack(spacing: AppSizes.Spacing.small) {
                Text("You're saying:")
                    .font(.system(size: AppSizes.FontSize.small))
                    .foregroundColor(AppColors.textTertiary)

                Text(viewModel.recognizedText.isEmpty ? "..." : viewModel.recognizedText)
                    .font(.system(size: AppSizes.FontSize.medium))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 50)
            }
            .padding(.horizontal)

            Spacer()

            // Stop button
            Button(action: {
                viewModel.stopPractice()
            }) {
                HStack {
                    Image(systemName: "stop.fill")
                    Text("Stop Recording")
                }
                .font(.system(size: AppSizes.FontSize.medium, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSizes.Padding.vertical)
                .background(Color.red)
                .cornerRadius(AppSizes.Radius.medium)
            }
            .padding(.horizontal, AppSizes.Padding.horizontal)
            .padding(.bottom, AppSizes.Padding.vertical)
        }
    }

    // MARK: - Evaluating View

    private var evaluatingView: some View {
        VStack(spacing: AppSizes.Spacing.large) {
            Spacer()

            ProgressView()
                .scaleEffect(1.5)

            Text("Evaluating your pronunciation...")
                .font(.system(size: AppSizes.FontSize.medium))
                .foregroundColor(AppColors.textSecondary)

            Spacer()
        }
    }

    // MARK: - Error View

    private var errorView: some View {
        VStack(spacing: AppSizes.Spacing.xlarge) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            VStack(spacing: AppSizes.Spacing.medium) {
                Text("Permission Required")
                    .font(.system(size: AppSizes.FontSize.large, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Text(errorMessage)
                    .font(.system(size: AppSizes.FontSize.medium))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: AppSizes.Spacing.medium) {
                // Open Settings button
                Button(action: openSettings) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Open Settings")
                    }
                    .font(.system(size: AppSizes.FontSize.medium, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSizes.Padding.vertical)
                    .background(AppColors.accent)
                    .cornerRadius(AppSizes.Radius.medium)
                }

                // Retry button
                Button(action: {
                    viewModel.reset()
                }) {
                    Text("Try Again")
                        .font(.system(size: AppSizes.FontSize.medium, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            .padding(.horizontal, AppSizes.Padding.horizontal)
            .padding(.bottom, AppSizes.Padding.vertical)
        }
    }

    // MARK: - Helpers

    private var errorMessage: String {
        switch viewModel.error {
        case .notAuthorized:
            return "Please allow microphone and speech recognition access in Settings to practice pronunciation."
        case .notAvailable:
            return "Speech recognition is not available on this device."
        case .audioEngineError:
            return "Failed to start audio recording. Please try again."
        case .recognitionFailed(let message):
            return "Recognition failed: \(message)"
        case nil:
            return "An unknown error occurred."
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview

#Preview {
    SpeechPracticeSheet(
        expression: PreviewData.singleExpression
    )
    .modelContainer(PreviewData.container)
}
