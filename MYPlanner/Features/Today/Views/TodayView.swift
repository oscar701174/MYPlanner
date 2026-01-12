//
//  TodayView.swift
//  MYPlanner
//
//  Today tab - displays schedule list for selected date
//  Uses SwiftData @Query for fetching schedules
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Schedule.createdAt) private var allSchedules: [Schedule]

    @State private var selectedSchedule: Schedule?

    // Filter schedules for selected date
    private var schedules: [Schedule] {
        allSchedules.filter { $0.isSameDay(as: calendarViewModel.selectedDate) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSizes.Spacing.extraLarge) {
                // Date Navigation
                DateIndicatorView(dateType: .day)
                    .frame(height: AppSizes.Height.dateIndicator)

                // Schedule List
                if schedules.isEmpty {
                    emptyStateView
                } else {
                    scheduleListView
                }

                Spacer()
            }
            .padding(.horizontal, AppSizes.Padding.horizontal)
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .navigationDestination(item: $selectedSchedule) { schedule in
                MyWordsView(schedule: schedule)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    // MARK: - Add Button
    private var addButton: some View {
        NavigationLink {
            ScheduleView()
                .environment(calendarViewModel)
        } label: {
            Text("⊕")
                .font(.system(size: AppSizes.Height.button))
                .foregroundColor(AppColors.accent)
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: AppSizes.Spacing.large) {
            Text("📅")
                .font(.system(size: 48))

            Text("일정이 없습니다")
                .font(.system(size: AppSizes.FontSize.medium))
                .foregroundColor(AppColors.textSecondary)

            Text("Schedule 탭에서 일정을 추가해보세요")
                .font(.system(size: AppSizes.FontSize.body))
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Schedule List
    private var scheduleListView: some View {
        ScrollView {
            LazyVStack(spacing: AppSizes.Spacing.large) {
                ForEach(schedules) { schedule in
                    ScheduleCard(schedule: schedule) {
                        navigateToDetail(schedule)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteSchedule(schedule)
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Actions
    private func navigateToDetail(_ schedule: Schedule) {
        selectedSchedule = schedule
    }

    private func deleteSchedule(_ schedule: Schedule) {
        modelContext.delete(schedule)
    }
}

// MARK: - Preview

#Preview {
    TodayView()
        .environment(CalendarViewModel())
        .modelContainer(PreviewData.container)
}

#Preview("Empty State") {
    TodayView()
        .environment(CalendarViewModel())
        .modelContainer(PreviewData.emptyContainer)
}
