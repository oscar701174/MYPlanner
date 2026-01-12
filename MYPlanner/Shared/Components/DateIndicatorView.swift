//
//  DateIndicatorView.swift
//  MYPlanner
//
//  Date navigation component with previous/next buttons
//

import SwiftUI

enum CalendarType {
    case year
    case month
    case day
}

struct DateIndicatorView: View {
    @Environment(CalendarViewModel.self) var calendarViewModel
    private var dateType: CalendarType = .day

    init(dateType: CalendarType = .day) {
        self.dateType = dateType
    }

    var displayText: String {
        switch dateType {
        case .year:
            return calendarViewModel.displayedMonth.yearString
        case .month:
            return calendarViewModel.displayedMonth.monthYearString
        case .day:
            return calendarViewModel.selectedDate.dayMonthYearString
        }
    }

    var body: some View {
        HStack {
            Button(action: { previous() }) {
                Image(systemName: "arrowtriangle.left.fill")
                    .foregroundColor(AppColors.textSecondary)
            }

            Text(displayText)
                .font(.system(size: AppSizes.FontSize.body, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .onTapGesture {
                    calendarViewModel.goToToday()
                }

            Button(action: { next() }) {
                Image(systemName: "arrowtriangle.right.fill")
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    private func previous() {
        switch dateType {
        case .year:
            calendarViewModel.displayedMonth = calendarViewModel.displayedMonth.previousYear
        case .month:
            calendarViewModel.previousMonth()
        case .day:
            calendarViewModel.previousDay()
        }
    }

    private func next() {
        switch dateType {
        case .year:
            calendarViewModel.displayedMonth = calendarViewModel.displayedMonth.nextYear
        case .month:
            calendarViewModel.nextMonth()
        case .day:
            calendarViewModel.nextDay()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DateIndicatorView(dateType: .month)
        DateIndicatorView(dateType: .day)
    }
    .environment(CalendarViewModel())
}
