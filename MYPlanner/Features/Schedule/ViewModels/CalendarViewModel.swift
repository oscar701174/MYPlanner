
import Foundation

@Observable
class CalendarViewModel {
    var date: Date = Date()
    var day: String {
        date.dayString
    }
    var month: String {
        date.monthString
    }
    var year: String {
        date.yearString
    }
}

