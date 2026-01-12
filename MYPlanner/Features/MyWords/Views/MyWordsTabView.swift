//
//  MyWordsTabView.swift
//  MYPlanner
//
//  My Words tab wrapper - displays schedules with expressions
//  User can tap to navigate to MyWordsView detail
//

import SwiftUI

struct MyWordsTabView: View {
    @State private var schedules: [Schedule] = PreviewData.schedules.filter { !$0.expressions.isEmpty }
    @State private var selectedSchedule: Schedule?

    // MARK: - Design Constants
    private enum Design {
        static let horizontalPadding: CGFloat = 16
        static let cardSpacing: CGFloat = 12
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if schedules.isEmpty {
                    emptyState
                } else {
                    scheduleList
                }
            }
            .padding(.horizontal, Design.horizontalPadding)
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
            LazyVStack(spacing: Design.cardSpacing) {
                ForEach(schedules) { schedule in
                    ScheduleExpressionCard(schedule: schedule) {
                        selectedSchedule = schedule
                    }
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("📖")
                .font(.system(size: 48))
            Text("아직 학습할 표현이 없습니다")
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
            Text("일정을 추가하고 영어 표현을 생성해보세요")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Schedule Expression Card

private struct ScheduleExpressionCard: View {
    let schedule: Schedule
    var onTap: (() -> Void)?

    private enum Design {
        static let cardHeight: CGFloat = 72
        static let cardCornerRadius: CGFloat = 12
        static let titleFontSize: CGFloat = 16
        static let countFontSize: CGFloat = 14
        static let horizontalPadding: CGFloat = 16
    }

    var body: some View {
        Button(action: { onTap?() }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(schedule.title)
                        .font(.system(size: Design.titleFontSize, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)

                    Text("\(schedule.expressions.count)개 표현")
                        .font(.system(size: Design.countFontSize))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Text("▶")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.accentText)
                    .frame(width: 32, height: 32)
                    .background(AppColors.accent)
                    .cornerRadius(8)
            }
            .padding(.horizontal, Design.horizontalPadding)
            .frame(height: Design.cardHeight)
            .background(AppColors.surface)
            .cornerRadius(Design.cardCornerRadius)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    MyWordsTabView()
}
