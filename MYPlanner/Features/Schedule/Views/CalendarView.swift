import SwiftUI

struct CalendarView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel

    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    // TODO: Replace with actual events from SwiftData
    private let datesWithEvents: Set<Int> = [5, 15, 22, 26]

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
            ForEach(Array(calendarViewModel.date.calendarGridDates().enumerated()), id: \.offset) { index, date in
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
        date.isSameDay(as: calendarViewModel.date)
    }

    private func hasEvent(on date: Date) -> Bool {
        // TODO: Check actual events from SwiftData
        datesWithEvents.contains(date.day)
    }

    private func selectDate(_ date: Date) {
        calendarViewModel.date = date
    }
}

#Preview {
    CalendarView()
        .environment(CalendarViewModel())
}
