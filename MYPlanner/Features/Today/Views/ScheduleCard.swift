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

    var body: some View {
        HStack {
            // Schedule title
            Text(schedule.title)
                .font(.system(size: AppSizes.FontSize.medium, weight: .regular))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)

            Spacer()

            // Arrow button
            Button(action: { onTap?() }) {
                Text("▶")
                    .font(.system(size: AppSizes.FontSize.body))
                    .foregroundColor(AppColors.accentText)
                    .frame(width: AppSizes.Width.buttonSmall, height: AppSizes.Height.button)
                    .background(AppColors.accent)
                    .cornerRadius(AppSizes.Radius.medium)
            }
        }
        .padding(.horizontal, AppSizes.Padding.horizontal)
        .frame(height: AppSizes.Height.card)
        .background(AppColors.surface)
        .cornerRadius(AppSizes.Radius.large)
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
