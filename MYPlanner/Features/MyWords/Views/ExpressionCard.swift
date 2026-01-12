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

struct ExpressionCard: View {
    let index: Int
    let expression: Expression
    var onListen: (() -> Void)?
    var onSpeak: (() -> Void)?

    // MARK: - Design Constants (from Figma)
    private enum Design {
        static let cardHeight: CGFloat = 139
        static let cardCornerRadius: CGFloat = 12
        static let borderWidth: CGFloat = 1
        static let padding: CGFloat = 16
        static let expressionFontSize: CGFloat = 16
        static let contentSpacing: CGFloat = 12
        static let accentRowSpacing: CGFloat = 8
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Design.contentSpacing) {
            // Expression text
            Text("\(index). \(expression.english)")
                .font(.system(size: Design.expressionFontSize))
                .foregroundColor(AppColors.textPrimary)

            // Accent row: Listen button + accent text
            HStack(spacing: Design.accentRowSpacing) {
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
        .padding(Design.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: Design.cardHeight)
        .background(AppColors.background)
        .cornerRadius(Design.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Design.cardCornerRadius)
                .stroke(AppColors.border, lineWidth: Design.borderWidth)
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        ExpressionCard(
            index: 1,
            expression: Expression(
                english: "Prepare for the product meeting.",
                accent: "pre-PARE for the PRO-duct MEET-ing"
            )
        ) {
            print("Listen tapped")
        } onSpeak: {
            print("Speak tapped")
        }

        ExpressionCard(
            index: 2,
            expression: Expression(
                english: "Get ready for the product meeting.",
                accent: "get REA-dy for the PRO-duct MEET-ing"
            )
        )
    }
    .padding()
}
