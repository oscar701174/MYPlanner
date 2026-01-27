//
//  MyWordsTabView.swift
//  MYPlanner
//
//  My Words tab - displays favorited expressions
//  Uses SwiftData @Query for fetching expressions
//

import SwiftUI
import SwiftData

struct MyWordsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expression.createdAt, order: .reverse) private var allExpressions: [Expression]
    @State private var ttsService = TTSService()
    @State private var speakingExpressionId: UUID?
    @State private var practiceExpression: Expression?

    // Filter favorited expressions
    private var favoritedExpressions: [Expression] {
        allExpressions.filter { $0.isFavorite }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSizes.Spacing.extraLarge) {
                if favoritedExpressions.isEmpty {
                    emptyState
                } else {
                    expressionList
                }
            }
            .padding(.horizontal, AppSizes.Padding.horizontal)
            .navigationTitle("My Words")
            .navigationBarTitleDisplayMode(.large)
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

    // MARK: - Expression List
    private var expressionList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(favoritedExpressions.enumerated()), id: \.element.id) { index, expression in
                    FavoriteExpressionCard(
                        index: index + 1,
                        expression: expression,
                        isListening: ttsService.isSpeaking && speakingExpressionId == expression.id,
                        currentSpeakingWord: speakingExpressionId == expression.id ? ttsService.currentWord : nil,
                        practiceExpression: $practiceExpression,
                        onListen: { handleListen(expression) },
                        onFavoriteToggle: { toggleFavorite(expression) },
                        onDelete: { deleteExpression(expression) }
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppSizes.Spacing.large) {
            Text("⭐")
                .font(.system(size: 48))
            Text("즐겨찾기한 표현이 없습니다")
                .font(.system(size: AppSizes.FontSize.medium))
                .foregroundColor(AppColors.textSecondary)
            Text("Today 탭에서 표현의 ☆를 눌러 즐겨찾기하세요")
                .font(.system(size: AppSizes.FontSize.body))
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions
    private func handleListen(_ expression: Expression) {
        if ttsService.isSpeaking && speakingExpressionId == expression.id {
            ttsService.stop()
            speakingExpressionId = nil
        } else {
            speakingExpressionId = expression.id
            ttsService.speak(expression.english)
        }
    }

    private func toggleFavorite(_ expression: Expression) {
        expression.isFavorite.toggle()
    }

    private func deleteExpression(_ expression: Expression) {
        modelContext.delete(expression)
    }
}

// MARK: - FavoriteExpressionCard

/// Expression card using Binding for speech practice sheet
/// This fixes SwiftUI's closure capture issue in List/ForEach
private struct FavoriteExpressionCard: View {
    let index: Int
    let expression: Expression
    let isListening: Bool
    let currentSpeakingWord: String?
    @Binding var practiceExpression: Expression?
    let onListen: () -> Void
    let onFavoriteToggle: () -> Void
    let onDelete: () -> Void

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

            // Speak button row with spoken accent
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

                // Spoken accent (user's pronunciation stress pattern)
                if let record = lastRecord, let spokenAccent = record.spokenAccent, !spokenAccent.isEmpty {
                    AccentLabel(
                        accent: spokenAccent,
                        originalText: record.recognizedText,
                        highlightedWord: nil
                    )
                }
            }

            // Delete button
            HStack {
                Spacer()
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("삭제", systemImage: "trash")
                        .font(.system(size: AppSizes.FontSize.small))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
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

// MARK: - Preview

#Preview {
    MyWordsTabView()
        .modelContainer(PreviewData.container)
}

#Preview("Empty") {
    MyWordsTabView()
        .modelContainer(PreviewData.emptyContainer)
}
