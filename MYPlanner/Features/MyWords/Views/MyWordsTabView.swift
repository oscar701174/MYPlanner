//
//  MyWordsTabView.swift
//  MYPlanner
//
//  My Words tab wrapper - displays schedules with expressions
//  Uses SwiftData @Query for fetching schedules
//

import SwiftUI
import SwiftData

struct MyWordsTabView: View {
    @Query(sort: \Schedule.createdAt, order: .reverse) private var allSchedules: [Schedule]
    @State private var selectedSchedule: Schedule?

    // Filter schedules that have expressions
    private var schedulesWithExpressions: [Schedule] {
        allSchedules.filter { !$0.expressions.isEmpty }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSizes.Spacing.extraLarge) {
                if schedulesWithExpressions.isEmpty {
                    emptyState
                } else {
                    scheduleList
                }
            }
            .padding(.horizontal, AppSizes.Padding.horizontal)
            .navigationTitle("My Words")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedSchedule) { schedule in
                MyWordsView(schedule: schedule)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    // MARK: - Schedule List
    private var scheduleList: some View {
        ScrollView {
            LazyVStack(spacing: AppSizes.Spacing.large) {
                ForEach(schedulesWithExpressions) { schedule in
                    ScheduleExpressionCard(schedule: schedule) {
                        selectedSchedule = schedule
                    }
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppSizes.Spacing.large) {
            Text("📖")
                .font(.system(size: 48))
            Text("아직 학습할 표현이 없습니다")
                .font(.system(size: AppSizes.FontSize.medium))
                .foregroundColor(AppColors.textSecondary)
            Text("일정을 추가하고 영어 표현을 생성해보세요")
                .font(.system(size: AppSizes.FontSize.body))
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Schedule Expression Card

private struct ScheduleExpressionCard: View {
    let schedule: Schedule
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            HStack {
                VStack(alignment: .leading, spacing: AppSizes.Spacing.small) {
                    Text(schedule.title)
                        .font(.system(size: AppSizes.FontSize.medium, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)

                    Text("\(schedule.expressions.count)개 표현")
                        .font(.system(size: AppSizes.FontSize.body))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Text("▶")
                    .font(.system(size: AppSizes.FontSize.body))
                    .foregroundColor(AppColors.accentText)
                    .frame(width: AppSizes.Width.buttonSmall, height: AppSizes.Height.button)
                    .background(AppColors.accent)
                    .cornerRadius(AppSizes.Radius.medium)
            }
            .padding(.horizontal, AppSizes.Padding.horizontal)
            .frame(height: AppSizes.Height.card)
            .background(AppColors.surface)
            .cornerRadius(AppSizes.Radius.large)
        }
        .buttonStyle(.plain)
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
