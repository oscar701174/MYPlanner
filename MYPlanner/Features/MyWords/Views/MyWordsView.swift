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

    var body: some View {
        NavigationStack {
            List {
                // Header Section
                Section {
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
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                // Expression Cards
                Section {
                    ForEach(Array(schedule.expressions.enumerated()), id: \.element.id) { index, expression in
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
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
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
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
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

// MARK: - Preview

#Preview {
    MyWordsView(schedule: PreviewData.singleSchedule)
        .modelContainer(PreviewData.container)
}
