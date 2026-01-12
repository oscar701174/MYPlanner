//
//  MyWordsView.swift
//  MYPlanner
//
//  My Words tab - English expression learning with TTS and speech recognition
//  Matching Figma "3. My Words" design
//

import SwiftUI

struct MyWordsView: View {
    let schedule: Schedule
    @Environment(\.dismiss) private var dismiss

    // MARK: - Design Constants (from Figma)
    private enum Design {
        static let horizontalPadding: CGFloat = 16
        static let tagSpacing: CGFloat = 8
        static let sectionSpacing: CGFloat = 12
        static let cardSpacing: CGFloat = 16
        static let sectionTitleFontSize: CGFloat = 16
        static let tagFontSize: CGFloat = 14
        static let tagHeight: CGFloat = 28
        static let tagCornerRadius: CGFloat = 14
        static let tagHorizontalPadding: CGFloat = 12
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Design.sectionSpacing) {
                    // Tags
                    tagsRow

                    // Title Card
                    TitleCard(title: schedule.title)

                    // Section Header
                    Text("유용한 영어 표현")
                        .font(.system(size: Design.sectionTitleFontSize))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.top, 8)

                    // Expression Cards
                    expressionList
                }
                .padding(.horizontal, Design.horizontalPadding)
                .padding(.top, Design.sectionSpacing)
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
            }
        }
    }

    // MARK: - Back Button
    private var backButton: some View {
        Button(action: { dismiss() }) {
            Text("◀")
                .font(.system(size: 20))
                .foregroundColor(AppColors.textPrimary)
        }
    }

    // MARK: - Tags Row
    private var tagsRow: some View {
        HStack(spacing: Design.tagSpacing) {
            hashTag(schedule.category.rawValue)

            // Additional tag based on category type
            if schedule.category == .meeting {
                hashTag("회의")
            }
        }
    }

    private func hashTag(_ text: String) -> some View {
        Text("#\(text)")
            .font(.system(size: Design.tagFontSize))
            .foregroundColor(AppColors.accent)
            .padding(.horizontal, Design.tagHorizontalPadding)
            .frame(height: Design.tagHeight)
            .background(Color(hex: "FFF2E0"))
            .cornerRadius(Design.tagCornerRadius)
    }

    // MARK: - Expression List
    private var expressionList: some View {
        VStack(spacing: Design.cardSpacing) {
            ForEach(Array(schedule.expressions.enumerated()), id: \.element.id) { index, expression in
                ExpressionCard(
                    index: index + 1,
                    expression: expression,
                    onListen: {
                        // TODO: User handles TTS function
                        print("Listen: \(expression.english)")
                    },
                    onSpeak: {
                        // TODO: User handles speech recognition
                        print("Speak: \(expression.english)")
                    }
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MyWordsView(schedule: PreviewData.singleSchedule)
}

#Preview("Multiple Expressions") {
    MyWordsView(
        schedule: Schedule(
            title: "상품 회의 준비하기",
            category: .work,
            expressions: [
                Expression(
                    english: "Prepare for the product meeting.",
                    accent: "pre-PARE for the PRO-duct MEET-ing"
                ),
                Expression(
                    english: "Get ready for the product meeting.",
                    accent: "get REA-dy for the PRO-duct MEET-ing"
                )
            ]
        )
    )
}
