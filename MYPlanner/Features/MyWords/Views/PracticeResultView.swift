//
//  PracticeResultView.swift
//  MYPlanner
//
//  발음 연습 결과를 표시하는 뷰
//  - 전체 점수 및 등급
//  - 단어별 발음 결과
//  - 다시 시도 버튼
//

import SwiftUI

struct PracticeResultView: View {
    let score: PronunciationScore
    let originalText: String
    let recognizedText: String
    var onRetry: (() -> Void)?
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: AppSizes.Spacing.xlarge) {
            // Header
            headerSection

            // Score display
            scoreSection

            // Word results
            wordResultsSection

            Spacer()

            // Action buttons
            actionButtons
        }
        .padding(AppSizes.Padding.horizontal)
        .background(AppColors.background)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppSizes.Spacing.small) {
            Text("Pronunciation Result")
                .font(.system(size: AppSizes.FontSize.xlarge, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text(originalText)
                .font(.system(size: AppSizes.FontSize.medium))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Score Section

    private var scoreSection: some View {
        VStack(spacing: AppSizes.Spacing.medium) {
            // Emoji and grade
            Text(score.grade.emoji)
                .font(.system(size: 64))

            Text(score.grade.message)
                .font(.system(size: AppSizes.FontSize.large, weight: .semibold))
                .foregroundColor(gradeColor)

            // Percentage
            Text("\(Int(score.overallAccuracy * 100))%")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(gradeColor)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.surface)
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(gradeColor)
                        .frame(width: geometry.size.width * CGFloat(score.overallAccuracy), height: 12)
                }
            }
            .frame(height: 12)
            .padding(.horizontal, AppSizes.Padding.horizontal)
        }
        .padding(.vertical, AppSizes.Padding.vertical)
    }

    // MARK: - Word Results Section

    private var wordResultsSection: some View {
        VStack(alignment: .leading, spacing: AppSizes.Spacing.medium) {
            Text("Word by Word")
                .font(.system(size: AppSizes.FontSize.medium, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSizes.Spacing.small) {
                    ForEach(Array(score.wordResults.enumerated()), id: \.offset) { _, wordResult in
                        WordResultChip(wordResult: wordResult)
                    }
                }
            }

            // Recognized text
            VStack(alignment: .leading, spacing: AppSizes.Spacing.xsmall) {
                Text("You said:")
                    .font(.system(size: AppSizes.FontSize.small))
                    .foregroundColor(AppColors.textTertiary)

                Text(recognizedText)
                    .font(.system(size: AppSizes.FontSize.medium))
                    .foregroundColor(AppColors.textSecondary)
                    .italic()
            }
            .padding(.top, AppSizes.Spacing.small)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: AppSizes.Spacing.medium) {
            // Retry button
            Button(action: { onRetry?() }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Try Again")
                }
                .font(.system(size: AppSizes.FontSize.medium, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSizes.Padding.vertical)
                .background(AppColors.accent)
                .cornerRadius(AppSizes.Radius.medium)
            }

            // Done button
            Button(action: { onDismiss?() }) {
                Text("Done")
                    .font(.system(size: AppSizes.FontSize.medium, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSizes.Padding.vertical)
                    .background(AppColors.surface)
                    .cornerRadius(AppSizes.Radius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSizes.Radius.medium)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            }
        }
        .padding(.bottom, AppSizes.Padding.vertical)
    }

    // MARK: - Helpers

    private var gradeColor: Color {
        switch score.grade {
        case .excellent:
            return .green
        case .good:
            return AppColors.accent
        case .fair:
            return .orange
        case .needsPractice:
            return .red
        }
    }
}

// MARK: - Word Result Chip

private struct WordResultChip: View {
    let wordResult: WordResult

    var body: some View {
        VStack(spacing: 4) {
            // Original word
            Text(wordResult.originalWord)
                .font(.system(size: AppSizes.FontSize.small, weight: .medium))
                .foregroundColor(statusColor)

            // Status icon
            Image(systemName: statusIcon)
                .font(.system(size: 12))
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(statusColor.opacity(0.1))
        .cornerRadius(AppSizes.Radius.small)
    }

    private var statusColor: Color {
        switch wordResult.status {
        case .correct:
            return .green
        case .mispronounced:
            return .orange
        case .missing:
            return .red
        case .extra:
            return .purple
        }
    }

    private var statusIcon: String {
        switch wordResult.status {
        case .correct:
            return "checkmark.circle.fill"
        case .mispronounced:
            return "exclamationmark.circle.fill"
        case .missing:
            return "minus.circle.fill"
        case .extra:
            return "plus.circle.fill"
        }
    }
}

// MARK: - Preview

#Preview {
    PracticeResultView(
        score: PronunciationScore(
            overallAccuracy: 0.75,
            wordResults: [
                WordResult(originalWord: "Prepare", recognizedWord: "Prepare", confidence: 0.9, status: .correct),
                WordResult(originalWord: "for", recognizedWord: "for", confidence: 0.95, status: .correct),
                WordResult(originalWord: "the", recognizedWord: "the", confidence: 0.98, status: .correct),
                WordResult(originalWord: "meeting", recognizedWord: "meating", confidence: 0.6, status: .mispronounced)
            ]
        ),
        originalText: "Prepare for the meeting",
        recognizedText: "Prepare for the meating"
    )
}
