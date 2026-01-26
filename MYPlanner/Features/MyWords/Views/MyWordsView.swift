//
//  MyWordsView.swift
//  MYPlanner
//
//  My Words tab - English expression learning with TTS and speech recognition
//  Matching Figma "3. My Words" design
//

import SwiftUI
import SwiftData

struct MyWordsView: View {
    let schedule: Schedule
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var ttsService = TTSService()
    @State private var speakingExpressionId: UUID?
    @State private var practiceExpression: Expression?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Header Section
                    VStack(alignment: .leading, spacing: AppSizes.Spacing.large) {
                        // Tags
                        tagsRow

                        // Title Card
                        TitleCard(title: schedule.title)

                        // Section Header
                        Text("유용한 영어 표현")
                            .font(.system(size: AppSizes.FontSize.medium))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.top, AppSizes.Spacing.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    // Expression Cards
                    ForEach(Array(schedule.expressions.enumerated()), id: \.element.id) { index, expression in
                        SimpleExpressionCard(
                            index: index + 1,
                            expression: expression,
                            isListening: ttsService.isSpeaking && speakingExpressionId == expression.id,
                            currentSpeakingWord: speakingExpressionId == expression.id ? ttsService.currentWord : nil,
                            practiceExpression: $practiceExpression,
                            onListen: { handleListen(expression) },
                            onFavoriteToggle: { toggleFavorite(expression) }
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
            }
            .onChange(of: ttsService.isSpeaking) { _, isSpeaking in
                if !isSpeaking {
                    speakingExpressionId = nil
                }
            }
            .sheet(item: $practiceExpression) { expression in
                SpeechPracticeSheet(expression: expression)
            }
        }
    }

    // MARK: - Back Button
    private var backButton: some View {
        Button(action: { dismiss() }) {
            Text("◀")
                .font(.system(size: AppSizes.FontSize.large))
                .foregroundColor(AppColors.textPrimary)
        }
    }

    // MARK: - Tags Row
    private var tagsRow: some View {
        HStack(spacing: AppSizes.Spacing.medium) {
            hashTag(schedule.category.rawValue)

            // Additional tag based on category type
            if schedule.category == .meeting {
                hashTag("회의")
            }
        }
    }

    private func hashTag(_ text: String) -> some View {
        Text("#\(text)")
            .font(.system(size: AppSizes.FontSize.body))
            .foregroundColor(AppColors.accent)
            .padding(.horizontal, AppSizes.Padding.medium)
            .frame(height: AppSizes.Height.tag)
            .background(AppColors.accentLight)
            .cornerRadius(AppSizes.Radius.pill)
    }

    // MARK: - Delete Expression
    private func deleteExpression(_ expression: Expression) {
        if let index = schedule.expressions.firstIndex(where: { $0.id == expression.id }) {
            schedule.expressions.remove(at: index)
            modelContext.delete(expression)
        }
    }

    // MARK: - Toggle Favorite
    private func toggleFavorite(_ expression: Expression) {
        expression.isFavorite.toggle()
    }

    // MARK: - TTS Actions
    private func handleListen(_ expression: Expression) {
        if ttsService.isSpeaking && speakingExpressionId == expression.id {
            ttsService.stop()
            speakingExpressionId = nil
        } else {
            speakingExpressionId = expression.id
            ttsService.speak(expression.english)
        }
    }
}

// MARK: - SimpleExpressionCard

/// Simplified expression card using Binding instead of closures for speak action
/// This fixes SwiftUI's closure capture issue
private struct SimpleExpressionCard: View {
    let index: Int
    let expression: Expression
    let isListening: Bool
    let currentSpeakingWord: String?
    @Binding var practiceExpression: Expression?
    let onListen: () -> Void
    let onFavoriteToggle: () -> Void

    private var lastRecord: PracticeRecord? {
        expression.lastPracticeRecord
    }

    private var practiceCount: Int {
        expression.practiceCount
    }

    var body: some View {
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
                Button(action: { onFavoriteToggle() }) {
                    Image(systemName: expression.isFavorite ? "star.fill" : "star")
                        .font(.system(size: AppSizes.FontSize.large))
                        .foregroundColor(expression.isFavorite ? AppColors.accent : AppColors.textTertiary)
                }
                .buttonStyle(.plain)
            }

            // Accent row: Listen button + accent text with highlighting
            HStack(spacing: AppSizes.Spacing.medium) {
                Button {
                    onListen()
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

            // Speak button row with word results
            HStack(spacing: AppSizes.Spacing.medium) {
                Button {
                    practiceExpression = expression
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

                // Word results as colored text
                if let record = lastRecord {
                    WordResultsText(wordResults: record.wordResults)
                }
            }
        }
        .padding(AppSizes.Padding.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: AppSizes.Height.cardLarge)
        .background(AppColors.background)
        .cornerRadius(AppSizes.Radius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppSizes.Radius.large)
                .stroke(AppColors.border, lineWidth: AppSizes.Border.width)
        )
        .animation(.easeInOut(duration: 0.15), value: currentSpeakingWord)
    }
}

// MARK: - Word Results Text

/// 단어별 결과를 하나의 문장으로 표시 (상태에 따라 색상 구분)
private struct WordResultsText: View {
    let wordResults: [WordResult]

    var body: some View {
        Text(buildAttributedString())
            .font(.system(size: AppSizes.FontSize.body))
    }

    private func buildAttributedString() -> AttributedString {
        var result: AttributedString = AttributedString()

        for (index, wordResult) in wordResults.enumerated() {
            var word: AttributedString = AttributedString(wordResult.originalWord)
            word.foregroundColor = statusColor(for: wordResult.status)

            result.append(word)

            // 단어 사이에 공백 추가 (마지막 단어 제외)
            if index < wordResults.count - 1 {
                result.append(AttributedString(" "))
            }
        }

        return result
    }

    private func statusColor(for status: WordStatus) -> Color {
        switch status {
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

// MARK: - Preview

#Preview {
    MyWordsView(schedule: PreviewData.singleSchedule)
        .modelContainer(PreviewData.container)
}
