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
    var isListening: Bool = false

    /// Current word being spoken (for highlighting)
    var currentSpeakingWord: String? = nil

    var onListen: (() -> Void)?
    var onSpeak: (() -> Void)?
    var onFavoriteToggle: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSizes.Spacing.large) {
            // Header: Expression text + Favorite button
            HStack(alignment: .top) {
                Text("\(index). \(expression.english)")
                    .font(.system(size: AppSizes.FontSize.medium))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

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
                ActionButton(type: .listen, isActive: isListening) {
                    onListen?()
                }

                AccentLabel(
                    accent: expression.accent,
                    originalText: expression.english,
                    highlightedWord: isListening ? currentSpeakingWord : nil
                )
            }

            // Speak button
            ActionButton(type: .speak) {
                onSpeak?()
            }
        }
        .padding(AppSizes.Padding.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: AppSizes.Height.cardLarge)
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
