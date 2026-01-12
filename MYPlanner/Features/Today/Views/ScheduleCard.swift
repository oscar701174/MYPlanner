//
//  ScheduleCard.swift
//  MYPlanner
//
//  Schedule card component matching Figma design
//  - Card with title and arrow button
//  - Navigate to detail/expression view
//

import SwiftUI

struct ScheduleCard: View {
    let schedule: Schedule
    var onTap: (() -> Void)?

    // MARK: - Design Constants (from Figma)
    private enum Design {
        static let cardHeight: CGFloat = 68
        static let cardCornerRadius: CGFloat = 12
        static let titleFontSize: CGFloat = 16
        static let buttonWidth: CGFloat = 32
        static let buttonHeight: CGFloat = 32
        static let buttonCornerRadius: CGFloat = 8
        static let arrowFontSize: CGFloat = 14
        static let horizontalPadding: CGFloat = 16
    }

    var body: some View {
        HStack {
            // Schedule title
            Text(schedule.title)
                .font(.system(size: Design.titleFontSize, weight: .regular))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)

            Spacer()

            // Arrow button
            Button(action: { onTap?() }) {
                Text("▶")
                    .font(.system(size: Design.arrowFontSize))
                    .foregroundColor(AppColors.accentText)
                    .frame(width: Design.buttonWidth, height: Design.buttonHeight)
                    .background(AppColors.accent)
                    .cornerRadius(Design.buttonCornerRadius)
            }
        }
        .padding(.horizontal, Design.horizontalPadding)
        .frame(height: Design.cardHeight)
        .background(AppColors.surface)
        .cornerRadius(Design.cardCornerRadius)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        ScheduleCard(
            schedule: Schedule(title: "회의 준비하기", category: .meeting),
            onTap: { print("Tapped") }
        )
        ScheduleCard(
            schedule: Schedule(title: "자동차 수리", category: .personal),
            onTap: { print("Tapped") }
        )
        ScheduleCard(
            schedule: Schedule(title: "저녁 준비하기", category: .other),
            onTap: { print("Tapped") }
        )
    }
    .padding()
}
