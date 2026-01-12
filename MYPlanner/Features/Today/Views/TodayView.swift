//
//  TodayView.swift
//  MYPlanner
//
//  Today tab - displays schedule list for selected date
//  Matching Figma "2. Today" design
//

import SwiftUI

struct TodayView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
    @State private var schedules: [Schedule] = PreviewData.todaySchedules
    @State private var selectedSchedule: Schedule?


    var body: some View {
        NavigationStack {
            VStack(spacing: AppSizes.Spacing.extraLarge) {
                // Date Navigation
                DateIndicatorView(dateType: .day)
                    .frame(height: AppSizes.Height.dateIndicator)

                // Schedule List
                scheduleListView

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
        Button(action: addSchedule) {
            Text("⊕")
                .font(.system(size: AppSizes.Height.button))
                .foregroundColor(AppColors.accent)
        }
    }

    // MARK: - Schedule List
    private var scheduleListView: some View {
        ScrollView {
            LazyVStack(spacing: AppSizes.Spacing.large) {
                ForEach(schedules) { schedule in
                    ScheduleCard(schedule: schedule) {
                        navigateToDetail(schedule)
                    }
                }
            }
        }
    }

    // MARK: - Actions
    private func addSchedule() {
        // TODO: Navigate to add schedule view or show sheet
        print("Add schedule tapped")
    }

    private func navigateToDetail(_ schedule: Schedule) {
        selectedSchedule = schedule
    }
}

// MARK: - Preview

#Preview {
    TodayView()
        .environment(CalendarViewModel())
}

#Preview("Empty State") {
    TodayView()
        .environment(CalendarViewModel())
}
