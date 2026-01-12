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

    // MARK: - Design Constants (from Figma)
    private enum Design {
        static let horizontalPadding: CGFloat = 16
        static let cardSpacing: CGFloat = 12
        static let addButtonSize: CGFloat = 32
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Date Navigation
                DateIndicatorView(dateType: .day)
                    .frame(height: 40)

                // Schedule List
                scheduleListView

                Spacer()
            }
            .padding(.horizontal, Design.horizontalPadding)
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
                .font(.system(size: Design.addButtonSize))
                .foregroundColor(AppColors.accent)
        }
    }

    // MARK: - Schedule List
    private var scheduleListView: some View {
        ScrollView {
            LazyVStack(spacing: Design.cardSpacing) {
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
