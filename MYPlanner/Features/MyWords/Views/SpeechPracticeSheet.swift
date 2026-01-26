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
    @Environment(\.modelContext) private var modelContext

    // Settings에서 선택한 엔진 사용
    @AppStorage("speechRecognitionEngine") private var selectedEngineRawValue: String = SpeechRecognitionEngineType.apple.rawValue

    @State private var viewModel: SpeechPracticeViewModel

    private var engineType: SpeechRecognitionEngineType {
        SpeechRecognitionEngineType(rawValue: selectedEngineRawValue) ?? .apple
    }

    init(expression: Expression) {
        self.expression = expression

        // AppStorage 기본값으로 초기 엔진 타입 결정
        let engineRawValue: String = UserDefaults.standard.string(forKey: "speechRecognitionEngine") ?? SpeechRecognitionEngineType.apple.rawValue
        let defaultEngine: SpeechRecognitionEngineType = SpeechRecognitionEngineType(rawValue: engineRawValue) ?? .apple
        self._viewModel = State(initialValue: SpeechPracticeViewModel(engineType: defaultEngine))
    }

    var body: some View {
        let english: String = expression.english
        let accent: String = expression.accent

        NavigationStack {
            VStack {
                switch viewModel.state {
                case .idle:
                    idleView(english: english, accent: accent)

                case .loading:
                    loadingView

                case .recording:
                    recordingView(accent: accent)

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
                                    await viewModel.startPractice(for: english)
                                }
                            },
                            onDismiss: {
                                savePracticeResult(score: score, viewModel: viewModel)
                                dismiss()
                            }
                        )
                    }

                case .error:
                    errorView(viewModel: viewModel)
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

    private func idleView(english: String, accent: String) -> some View {
        VStack(spacing: AppSizes.Spacing.xlarge) {
            Spacer()

            // Engine indicator
            HStack(spacing: AppSizes.Spacing.small) {
                Image(systemName: engineType.iconName)
                    .font(.system(size: AppSizes.FontSize.small))
                Text(engineType.displayName)
                    .font(.system(size: AppSizes.FontSize.small))
            }
            .foregroundColor(AppColors.textTertiary)
            .padding(.horizontal, AppSizes.Padding.small)
            .padding(.vertical, 4)
            .background(AppColors.surface)
            .cornerRadius(AppSizes.Radius.small)

            // Expression to practice (with accent notation)
            VStack(spacing: AppSizes.Spacing.medium) {
                Text("Say this expression:")
                    .font(.system(size: AppSizes.FontSize.medium))
                    .foregroundColor(AppColors.textSecondary)

                Text(accent)
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
                    await viewModel.startPractice(for: english)
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

    // MARK: - Loading View (WhisperKit model loading)

    private var loadingView: some View {
        VStack(spacing: AppSizes.Spacing.large) {
            Spacer()

            ProgressView()
                .scaleEffect(1.5)

            Text("Loading Whisper model...")
                .font(.system(size: AppSizes.FontSize.medium))
                .foregroundColor(AppColors.textSecondary)

            Text("This may take a moment on first use")
                .font(.system(size: AppSizes.FontSize.small))
                .foregroundColor(AppColors.textTertiary)

            Spacer()
        }
    }

    // MARK: - Recording View

    private func recordingView(accent: String) -> some View {
        VStack(spacing: AppSizes.Spacing.xlarge) {
            Spacer()

            // Expression being practiced (with accent notation)
            VStack(spacing: AppSizes.Spacing.medium) {
                Text("Listening...")
                    .font(.system(size: AppSizes.FontSize.medium))
                    .foregroundColor(AppColors.textSecondary)

                Text(accent)
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

    private func errorView(viewModel: SpeechPracticeViewModel) -> some View {
        VStack(spacing: AppSizes.Spacing.xlarge) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            VStack(spacing: AppSizes.Spacing.medium) {
                Text("Permission Required")
                    .font(.system(size: AppSizes.FontSize.large, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Text(errorMessage(for: viewModel))
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

    private func errorMessage(for viewModel: SpeechPracticeViewModel) -> String {
        switch viewModel.error {
        case .notAuthorized:
            if engineType == .whisper {
                return "Please allow microphone access in Settings to practice pronunciation."
            } else {
                return "Please allow microphone and speech recognition access in Settings to practice pronunciation."
            }
        case .notAvailable:
            if engineType == .whisper {
                return "Whisper model could not be loaded. Please try again."
            } else {
                return "Speech recognition is not available on this device."
            }
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

    // MARK: - Save Practice Result

    private func savePracticeResult(score: PronunciationScore, viewModel: SpeechPracticeViewModel) {
        let record: PracticeRecord = PracticeRecord(
            expression: expression,
            overallAccuracy: score.overallAccuracy,
            recognizedText: viewModel.recognizedText,
            originalText: viewModel.originalText,
            engineType: viewModel.currentEngineType.rawValue,
            wordResults: score.wordResults,
            practicedAt: Date()
        )

        // SwiftData에 레코드 삽입 (relationship은 자동 연결됨)
        modelContext.insert(record)
        expression.isPracticed = true

        // 변경사항 즉시 저장하여 동기화 보장
        try? modelContext.save()
    }
}

// MARK: - Preview

#Preview {
    SpeechPracticeSheet(
        expression: PreviewData.singleExpression
    )
    .modelContainer(PreviewData.container)
}
