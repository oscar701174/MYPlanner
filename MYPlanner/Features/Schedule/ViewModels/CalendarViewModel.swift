//
//  CalendarViewModel.swift
//  MYPlanner
//
//  Manages calendar state - current month display and selected date
//

import Foundation

@Observable
class CalendarViewModel {
    /// The currently selected date (for schedule input and today view)
    var selectedDate: Date = Date()

    /// The month being displayed in the calendar
    var displayedMonth: Date = Date()

    // MARK: - Display Helpers

    var dayString: String {
        selectedDate.dayString
    }

    var monthString: String {
        displayedMonth.monthString
    }

    var yearString: String {
        displayedMonth.yearString
    }

    // MARK: - Navigation

    func nextMonth() {
        displayedMonth = displayedMonth.nextMonth
    }

    func previousMonth() {
        displayedMonth = displayedMonth.previousMonth
    }

    func nextDay() {
        selectedDate = selectedDate.nextDay
    }

    func previousDay() {
        selectedDate = selectedDate.previousDay
    }

    /// Select a date and update displayed month if needed
    func selectDate(_ date: Date) {
        selectedDate = date
        if !date.isSameMonth(as: displayedMonth) {
            displayedMonth = date
        }
    }

    /// Go to today
    func goToToday() {
        selectedDate = Date()
        displayedMonth = Date()
    }
}
