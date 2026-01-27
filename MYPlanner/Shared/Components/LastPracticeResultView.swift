//
//  LastPracticeResultView.swift
//  MYPlanner
//
//  마지막 발음 연습 결과를 표시하는 컴포넌트
//  - 점수 및 등급 표시
//  - 단어별 결과 표시
//  - 악센트 대비 실제 발음 표시
//

import SwiftUI

struct LastPracticeResultView: View {
    let record: PracticeRecord
    let accentText: String

    /// 컴팩트 모드 (ExpressionCard 내부용)
    var isCompact: Bool = true

    var body: some View {
        // 데이터를 한 번만 캐시하여 사용
        let wordResults: [WordResult] = record.wordResults
        let grade: PronunciationGrade = record.grade
        let accuracy: Float = record.overallAccuracy
        let recognizedText: String = record.recognizedText
        let practicedAt: Date = record.practicedAt

        if isCompact {
            compactView(
                wordResults: wordResults,
                grade: grade,
                accuracy: accuracy,
                recognizedText: recognizedText,
                practicedAt: practicedAt
            )
        } else {
            fullView(
                wordResults: wordResults,
                grade: grade,
                accuracy: accuracy,
                recognizedText: recognizedText,
                practicedAt: practicedAt
            )
        }
    }

    // MARK: - Compact View (for ExpressionCard)

    private func compactView(
        wordResults: [WordResult],
        grade: PronunciationGrade,
        accuracy: Float,
        recognizedText: String,
        practicedAt: Date
    ) -> some View {
        let correctCount: Int = wordResults.filter { $0.status == .correct }.count
        let totalCount: Int = wordResults.filter { $0.status != .extra }.count
        let color: Color = gradeColor(for: grade)

        return VStack(alignment: .leading, spacing: AppSizes.Spacing.small) {
            // Header: Score + Grade
            HStack(spacing: AppSizes.Spacing.small) {
                // Grade emoji
                Text(grade.emoji)
                    .font(.system(size: AppSizes.FontSize.medium))

                // Score
                Text("\(Int(accuracy * 100))%")
                    .font(.system(size: AppSizes.FontSize.small, weight: .bold))
                    .foregroundColor(color)

                // Word count
                Text("\(correctCount)/\(totalCount)")
                    .font(.system(size: AppSizes.FontSize.small))
                    .foregroundColor(AppColors.textTertiary)

                Spacer()

                // Time ago
                Text(timeAgoText(from: practicedAt))
                    .font(.system(size: AppSizes.FontSize.small))
                    .foregroundColor(AppColors.textTertiary)
            }

            // Word results (horizontal scroll)
            if !wordResults.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(Array(wordResults.enumerated()), id: \.offset) { _, wordResult in
                            CompactWordChip(wordResult: wordResult)
                        }
                    }
                }
            }

            // Recognized text (what user said)
            HStack(spacing: AppSizes.Spacing.small) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 8))
                    .foregroundColor(AppColors.textTertiary)

                Text(recognizedText)
                    .font(.system(size: AppSizes.FontSize.small))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                    .italic()

                Image(systemName: "quote.closing")
                    .font(.system(size: 8))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(AppSizes.Padding.small)
        .background(color.opacity(0.05))
        .cornerRadius(AppSizes.Radius.small)
        .overlay(
            RoundedRectangle(cornerRadius: AppSizes.Radius.small)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Full View (for detailed display)

    private func fullView(
        wordResults: [WordResult],
        grade: PronunciationGrade,
        accuracy: Float,
        recognizedText: String,
        practicedAt: Date
    ) -> some View {
        let correctCount: Int = wordResults.filter { $0.status == .correct }.count
        let totalCount: Int = wordResults.filter { $0.status != .extra }.count
        let color: Color = gradeColor(for: grade)

        return VStack(alignment: .leading, spacing: AppSizes.Spacing.medium) {
            // Header
            HStack {
                Text("Last Practice")
                    .font(.system(size: AppSizes.FontSize.medium, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text(timeAgoText(from: practicedAt))
                    .font(.system(size: AppSizes.FontSize.small))
                    .foregroundColor(AppColors.textTertiary)
            }

            // Score section
            HStack(spacing: AppSizes.Spacing.medium) {
                // Grade emoji
                Text(grade.emoji)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: 4) {
                    // Score
                    Text("\(Int(accuracy * 100))%")
                        .font(.system(size: AppSizes.FontSize.xlarge, weight: .bold))
                        .foregroundColor(color)

                    // Grade message
                    Text(grade.message)
                        .font(.system(size: AppSizes.FontSize.small))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                // Word count badge
                VStack(spacing: 2) {
                    Text("\(correctCount)/\(totalCount)")
                        .font(.system(size: AppSizes.FontSize.medium, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    Text("words")
                        .font(.system(size: AppSizes.FontSize.small))
                        .foregroundColor(AppColors.textTertiary)
                }
            }

            // Accent comparison
            VStack(alignment: .leading, spacing: AppSizes.Spacing.small) {
                Text("Expected:")
                    .font(.system(size: AppSizes.FontSize.small))
                    .foregroundColor(AppColors.textTertiary)

                Text(accentText)
                    .font(.system(size: AppSizes.FontSize.small, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
            }

            // Spoken accent (강세 분석 결과)
            if let spokenAccent = record.spokenAccent, !spokenAccent.isEmpty {
                VStack(alignment: .leading, spacing: AppSizes.Spacing.small) {
                    Text("Your stress pattern:")
                        .font(.system(size: AppSizes.FontSize.small))
                        .foregroundColor(AppColors.textTertiary)

                    Text(spokenAccent)
                        .font(.system(size: AppSizes.FontSize.small, weight: .medium, design: .monospaced))
                        .foregroundColor(AppColors.accent)
                }
            }

            VStack(alignment: .leading, spacing: AppSizes.Spacing.small) {
                Text("You said:")
                    .font(.system(size: AppSizes.FontSize.small))
                    .foregroundColor(AppColors.textTertiary)

                Text(recognizedText)
                    .font(.system(size: AppSizes.FontSize.small))
                    .foregroundColor(AppColors.textSecondary)
                    .italic()
            }

            // Word results
            if !wordResults.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSizes.Spacing.small) {
                        ForEach(Array(wordResults.enumerated()), id: \.offset) { _, wordResult in
                            DetailedWordChip(wordResult: wordResult)
                        }
                    }
                }
            }
        }
        .padding(AppSizes.Padding.horizontal)
        .background(AppColors.surface)
        .cornerRadius(AppSizes.Radius.medium)
    }

    // MARK: - Helpers

    private func gradeColor(for grade: PronunciationGrade) -> Color {
        switch grade {
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

    private func timeAgoText(from date: Date) -> String {
        let formatter: RelativeDateTimeFormatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Compact Word Chip

private struct CompactWordChip: View {
    let wordResult: WordResult

    var body: some View {
        Text(wordResult.originalWord)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(statusColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.15))
            .cornerRadius(4)
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
}

// MARK: - Detailed Word Chip

private struct DetailedWordChip: View {
    let wordResult: WordResult

    var body: some View {
        VStack(spacing: 2) {
            // Original word
            Text(wordResult.originalWord)
                .font(.system(size: AppSizes.FontSize.small, weight: .medium))
                .foregroundColor(statusColor)

            // Status icon
            Image(systemName: statusIcon)
                .font(.system(size: 10))
                .foregroundColor(statusColor)

            // Recognized word (if different)
            if let recognized = wordResult.recognizedWord,
               wordResult.status == .mispronounced {
                Text(recognized)
                    .font(.system(size: 9))
                    .foregroundColor(AppColors.textTertiary)
                    .italic()
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
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

#Preview("Compact - Good") {
    LastPracticeResultView(
        record: PracticeRecord(
            overallAccuracy: 0.75,
            recognizedText: "Prepare for the meating",
            originalText: "Prepare for the meeting",
            engineType: "apple",
            wordResults: [
                WordResult(originalWord: "Prepare", recognizedWord: "Prepare", confidence: 0.9, status: .correct),
                WordResult(originalWord: "for", recognizedWord: "for", confidence: 0.95, status: .correct),
                WordResult(originalWord: "the", recognizedWord: "the", confidence: 0.98, status: .correct),
                WordResult(originalWord: "meeting", recognizedWord: "meating", confidence: 0.6, status: .mispronounced)
            ]
        ),
        accentText: "pre-PARE for the MEET-ing",
        isCompact: true
    )
    .padding()
}

#Preview("Full - Excellent") {
    LastPracticeResultView(
        record: PracticeRecord(
            overallAccuracy: 0.95,
            recognizedText: "Prepare for the meeting",
            originalText: "Prepare for the meeting",
            engineType: "whisper",
            wordResults: [
                WordResult(originalWord: "Prepare", recognizedWord: "Prepare", confidence: 0.95, status: .correct),
                WordResult(originalWord: "for", recognizedWord: "for", confidence: 0.95, status: .correct),
                WordResult(originalWord: "the", recognizedWord: "the", confidence: 0.98, status: .correct),
                WordResult(originalWord: "meeting", recognizedWord: "meeting", confidence: 0.92, status: .correct)
            ]
        ),
        accentText: "pre-PARE for the MEET-ing",
        isCompact: false
    )
    .padding()
}
