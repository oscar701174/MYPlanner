//
//  ExpressionCard.swift
//  MYPlanner
//
//  Expression card component matching Figma design
//  - White background with border
//  - English expression with accent visualization
//  - Listen and speak action buttons
//  - Word-by-word highlighting during TTS playback
//

import SwiftUI
import SwiftData

struct ExpressionCard: View {
    let index: Int
    let expression: Expression
    let isListening: Bool
    let currentSpeakingWord: String?
    let onListen: (() -> Void)?
    let onSpeak: (() -> Void)?
    let onFavoriteToggle: (() -> Void)?

    init(
        index: Int,
        expression: Expression,
        isListening: Bool = false,
        currentSpeakingWord: String? = nil,
        onListen: (() -> Void)? = nil,
        onSpeak: (() -> Void)? = nil,
        onFavoriteToggle: (() -> Void)? = nil
    ) {
        self.index = index
        self.expression = expression
        self.isListening = isListening
        self.currentSpeakingWord = currentSpeakingWord
        self.onListen = onListen
        self.onSpeak = onSpeak
        self.onFavoriteToggle = onFavoriteToggle
    }

    /// 연습 기록 캐시 (한 번만 접근하여 저장)
    private var cachedLastRecord: PracticeRecord? {
        expression.lastPracticeRecord
    }

    /// 연습 횟수 캐시
    private var cachedPracticeCount: Int {
        expression.practiceCount
    }

    var body: some View {
        let lastRecord: PracticeRecord? = cachedLastRecord
        let practiceCount: Int = cachedPracticeCount
        let hasLastPractice: Bool = lastRecord != nil

        VStack(alignment: .leading, spacing: AppSizes.Spacing.medium) {
            // Header: Expression text + Favorite button
            HStack(alignment: .top) {
                Text("\(index). \(expression.english)")
                    .font(.system(size: AppSizes.FontSize.medium))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                // Practice count badge (if practiced)
                if practiceCount > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 10))
                        Text("\(practiceCount)")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(AppColors.accent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColors.accentLight)
                    .cornerRadius(AppSizes.Radius.small)
                }

                // Favorite button
                Button(action: { onFavoriteToggle?() }) {
                    Image(systemName: expression.isFavorite ? "star.fill" : "star")
                        .font(.system(size: AppSizes.FontSize.large))
                        .foregroundColor(expression.isFavorite ? AppColors.accent : AppColors.textTertiary)
                }
                .buttonStyle(.plain)
            }

            // Accent row: Listen button + accent text with highlighting
            HStack(spacing: AppSizes.Spacing.medium) {
                Button {
                    onListen?()
                } label: {
                    Text("듣기")
                        .font(.system(size: AppSizes.FontSize.body))
                        .foregroundColor(AppColors.accentText)
                        .padding(.horizontal, AppSizes.Padding.medium)
                        .frame(height: AppSizes.Height.button)
                        .background(isListening ? AppColors.accent.opacity(0.7) : AppColors.accent)
                        .cornerRadius(AppSizes.Radius.small)
                }
                .buttonStyle(.plain)

                AccentLabel(
                    accent: expression.accent,
                    originalText: expression.english,
                    highlightedWord: isListening ? currentSpeakingWord : nil
                )
            }

            // Speak button row with recognized text
            HStack(spacing: AppSizes.Spacing.medium) {
                Button {
                    onSpeak?()
                } label: {
                    Text("말하기")
                        .font(.system(size: AppSizes.FontSize.body))
                        .foregroundColor(AppColors.accentText)
                        .padding(.horizontal, AppSizes.Padding.medium)
                        .frame(height: AppSizes.Height.button)
                        .background(AppColors.accent)
                        .cornerRadius(AppSizes.Radius.small)
                }
                .buttonStyle(.plain)

                // Recognized text with word-level coloring
                if let record = lastRecord {
                    RecognizedTextLabel(record: record)
                }
            }
        }
        .padding(AppSizes.Padding.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: hasLastPractice ? AppSizes.Height.cardLarge + 80 : AppSizes.Height.cardLarge)
        .background(AppColors.background)
        .cornerRadius(AppSizes.Radius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppSizes.Radius.large)
                .stroke(AppColors.border, lineWidth: AppSizes.Border.width)
        )
        .animation(.easeInOut(duration: 0.15), value: currentSpeakingWord)
    }

}

// MARK: - RecognizedTextLabel

/// 인식된 문장을 accent 형식으로 변환하여 점수와 함께 표시
private struct RecognizedTextLabel: View {
    let record: PracticeRecord

    /// 인식된 텍스트를 accent 형식으로 변환
    private var accentFormattedText: String {
        AccentFormatter.shared.format(record.recognizedText)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 인식된 문장 (accent 형식)
            AccentLabel(
                accent: accentFormattedText,
                originalText: record.recognizedText,
                highlightedWord: nil
            )

            // 점수 표시
            HStack(spacing: 4) {
                Text(record.grade.emoji)
                    .font(.system(size: 10))
                Text("\(Int(record.overallAccuracy * 100))%")
                    .font(.system(size: AppSizes.FontSize.small, weight: .medium))
                    .foregroundColor(gradeColor(for: record.grade))
            }
        }
    }

    private func gradeColor(for grade: PronunciationGrade) -> Color {
        switch grade {
        case .excellent: return .green
        case .good: return AppColors.accent
        case .fair: return .orange
        case .needsPractice: return .red
        }
    }
}

// MARK: - Preview

#Preview("Normal") {
    VStack(spacing: 16) {
        ExpressionCard(
            index: 1,
            expression: PreviewData.singleExpression
        ) {
            print("Listen tapped")
        } onSpeak: {
            print("Speak tapped")
        }
    }
    .padding()
    .modelContainer(PreviewData.container)
}

#Preview("With Highlight") {
    VStack(spacing: 16) {
        // Simulating TTS highlighting "meeting"
        ExpressionCard(
            index: 1,
            expression: PreviewData.singleExpression,
            isListening: true,
            currentSpeakingWord: "meeting"
        )
    }
    .padding()
    .modelContainer(PreviewData.container)
}

#Preview("With Practice Record") {
    VStack(spacing: 16) {
        ExpressionCard(
            index: 1,
            expression: PreviewData.expressionWithPracticeRecord
        )
    }
    .padding()
    .modelContainer(PreviewData.container)
}
