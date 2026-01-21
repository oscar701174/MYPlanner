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
        }
    }

    // MARK: - Expression List
    private var expressionList: some View {
        List {
            ForEach(Array(favoritedExpressions.enumerated()), id: \.element.id) { index, expression in
                ExpressionCard(
                    index: index + 1,
                    expression: expression,
                    isListening: ttsService.isSpeaking && speakingExpressionId == expression.id,
                    currentSpeakingWord: speakingExpressionId == expression.id ? ttsService.currentWord : nil,
                    onListen: {
                        handleListen(expression)
                    },
                    onSpeak: {
                        // TODO: Step 11 - Speech recognition
                        print("Speak: \(expression.english)")
                    },
                    onFavoriteToggle: {
                        toggleFavorite(expression)
                    }
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteExpression(expression)
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
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

// MARK: - Preview

#Preview {
    MyWordsTabView()
        .modelContainer(PreviewData.container)
}

#Preview("Empty") {
    MyWordsTabView()
        .modelContainer(PreviewData.emptyContainer)
}
