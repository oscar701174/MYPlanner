//
//  CalendarView.swift
//  MYPlanner
//
//  Monthly calendar grid with date selection and event indicators
//  Uses SwiftData @Query to show event dots
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
    @Query(sort: \Schedule.date) private var allSchedules: [Schedule]

    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            // Weekday header
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.system(size: AppSizes.FontSize.body, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(height: 30)
            }

            // Calendar days
            ForEach(Array(calendarViewModel.displayedMonth.calendarGridDates().enumerated()), id: \.offset) { index, date in
                if let date = date {
                    CalendarDayCell(
                        date: date,
                        isSelected: isSelected(date),
                        hasEvent: hasEvent(on: date),
                        onTap: { selectDate(date) }
                    )
                    .frame(height: AppSizes.Height.navBar)
                } else {
                    // Empty cell for days before first day of month
                    Color.clear
                        .frame(height: AppSizes.Height.navBar)
                }
            }
        }
        .padding(.horizontal, AppSizes.Padding.medium)
    }

    // MARK: - Helper Methods

    private func isSelected(_ date: Date) -> Bool {
        date.isSameDay(as: calendarViewModel.selectedDate)
    }

    private func hasEvent(on date: Date) -> Bool {
        allSchedules.contains { $0.isSameDay(as: date) }
    }

    private func selectDate(_ date: Date) {
        calendarViewModel.selectDate(date)
    }
}

#Preview {
    CalendarView()
        .environment(CalendarViewModel())
        .modelContainer(PreviewData.container)
}
