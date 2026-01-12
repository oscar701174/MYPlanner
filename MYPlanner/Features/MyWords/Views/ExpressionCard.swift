//
//  ExpressionCard.swift
//  MYPlanner
//
//  Expression card component matching Figma design
//  - White background with border
//  - English expression with accent visualization
//  - Listen and speak action buttons
//

import SwiftUI
import SwiftData

struct ExpressionCard: View {
    let index: Int
    let expression: Expression
    var onListen: (() -> Void)?
    var onSpeak: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSizes.Spacing.large) {
            // Expression text
            Text("\(index). \(expression.english)")
                .font(.system(size: AppSizes.FontSize.medium))
                .foregroundColor(AppColors.textPrimary)

            // Accent row: Listen button + accent text
            HStack(spacing: AppSizes.Spacing.medium) {
                ActionButton(type: .listen) {
                    onListen?()
                }

                AccentLabel(accent: expression.accent)
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
    }
}

// MARK: - Preview

#Preview {
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
