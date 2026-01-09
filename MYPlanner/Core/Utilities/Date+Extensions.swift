import Foundation

// MARK: - Date Extensions for Calendar
// Transferred from CalendarViewModel + additional helpers

extension Date {

    // MARK: - Calendar Instance

    private var calendar: Calendar { Calendar.current }

    // MARK: - Navigation (from CalendarViewModel)

    var nextYear: Date {
        calendar.date(byAdding: .year, value: 1, to: self) ?? self
    }
    
    var previousYear: Date {
        calendar.date(byAdding: .year, value: -1, to: self) ?? self
    }
    
    /// 다음 달 (plusMonth)
    var nextMonth: Date {
        calendar.date(byAdding: .month, value: 1, to: self) ?? self
    }

    /// 이전 달 (minusMonth)
    var previousMonth: Date {
        calendar.date(byAdding: .month, value: -1, to: self) ?? self
    }

    /// 다음 날 (plusDay)
    var nextDay: Date {
        calendar.date(byAdding: .day, value: 1, to: self) ?? self
    }

    /// 이전 날 (minusDay)
    var previousDay: Date {
        calendar.date(byAdding: .day, value: -1, to: self) ?? self
    }

    // MARK: - Components (from CalendarViewModel)

    /// 일(day) 값
    var day: Int {
        calendar.component(.day, from: self)
    }

    /// 월(month) 값
    var month: Int {
        calendar.component(.month, from: self)
    }

    /// 년(year) 값
    var year: Int {
        calendar.component(.year, from: self)
    }

    /// [day, month, year] 배열 (daysOfMonth)
    var dateComponentsArray: [Int] {
        [day, month, year]
    }

    /// 요일 인덱스 0-based (일=0, 토=6) (weekDay)
    var weekdayIndex: Int {
        calendar.component(.weekday, from: self) - 1
    }

    /// 요일 인덱스 1-based (일=1, 토=7)
    var weekday: Int {
        calendar.component(.weekday, from: self)
    }

    // MARK: - Month Calculations (from CalendarViewModel)

    /// 해당 월의 일수 (daysCountInMonth)
    var numberOfDaysInMonth: Int {
        calendar.range(of: .day, in: .month, for: self)?.count ?? 30
    }

    /// 해당 월 첫째 날의 요일 1-based (일=1, 토=7) (firstDayOfMonth)
    var firstWeekdayOfMonth: Int {
        let components = calendar.dateComponents([.year, .month], from: self)
        guard let firstDay = calendar.date(from: components) else { return 1 }
        return calendar.component(.weekday, from: firstDay)
    }

    /// 캘린더 그리드에서 첫째 날 앞의 빈 칸 수 (일요일 시작 기준)
    var startingSpaces: Int {
        firstWeekdayOfMonth - 1
    }

    /// 해당 월의 첫째 날
    var firstDayOfMonth: Date {
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    /// 해당 월의 마지막 날
    var lastDayOfMonth: Date {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth),
              let lastDay = calendar.date(byAdding: .day, value: -1, to: nextMonth) else {
            return self
        }
        return lastDay
    }

    // MARK: - Formatting (from CalendarViewModel)

    /// "dd" 형식 (dayString)
    var dayString: String {
        formatted(format: "dd", locale: "ko_KR")
    }

    /// "MM" 형식 (monthString)
    var monthString: String {
        formatted(format: "MM", locale: "ko_KR")
    }

    /// "yyyy" 형식 (yearString)
    var yearString: String {
        formatted(format: "yyyy", locale: "ko_KR")
    }

    /// "yyyy. MM " 형식 (monthYearString)
    var monthYearString: String {
        formatted(format: "yyyy. MM ", locale: "ko_KR")
    }

    /// "MM. yyyy " 형식 영문 (monthYearStringEng)
    var monthYearStringEng: String {
        formatted(format: "MM. yyyy ", locale: "en_US")
    }

    /// "yyyy. MM. dd" 형식 (dayMonthYearString)
    var dayMonthYearString: String {
        formatted(format: "yyyy. MM. dd", locale: "ko_KR")
    }

    /// "dd. MM. yyyy" 형식 영문 (dayMonthYearStringEng)
    var dayMonthYearStringEng: String {
        formatted(format: "dd. MM. yyyy", locale: "en_US")
    }

    // MARK: - Private Formatting Helper

    private func formatted(format: String, locale: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale)
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    // MARK: - Day Calculations

    /// 하루의 시작 시간 (00:00:00)
    var startOfDay: Date {
        calendar.startOfDay(for: self)
    }

    /// 하루의 끝 시간 (23:59:59)
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfDay) ?? self
    }

    // MARK: - Date Comparisons

    /// 오늘인지 확인
    var isToday: Bool {
        calendar.isDateInToday(self)
    }

    /// 같은 날인지 확인
    func isSameDay(as other: Date) -> Bool {
        calendar.isDate(self, inSameDayAs: other)
    }

    /// 같은 월인지 확인
    func isSameMonth(as other: Date) -> Bool {
        let selfComponents = calendar.dateComponents([.year, .month], from: self)
        let otherComponents = calendar.dateComponents([.year, .month], from: other)
        return selfComponents.year == otherComponents.year &&
               selfComponents.month == otherComponents.month
    }

    /// 주말인지 확인
    var isWeekend: Bool {
        calendar.isDateInWeekend(self)
    }

    // MARK: - Date Creation

    /// 특정 월의 날짜 배열 생성
    func datesOfMonth() -> [Date] {
        let range = calendar.range(of: .day, in: .month, for: self) ?? 1..<31
        return range.compactMap { day -> Date? in
            var components = calendar.dateComponents([.year, .month], from: self)
            components.day = day
            return calendar.date(from: components)
        }
    }

    /// 특정 일로 날짜 생성
    func date(withDay day: Int) -> Date? {
        var components = calendar.dateComponents([.year, .month], from: self)
        components.day = day
        return calendar.date(from: components)
    }

    /// 캘린더 그리드에 표시할 날짜 배열 (빈 칸 포함)
    func calendarGridDates() -> [Date?] {
        var dates: [Date?] = []

        // 첫째 날 앞의 빈 칸
        for _ in 0..<startingSpaces {
            dates.append(nil)
        }

        // 현재 월의 날짜들
        dates.append(contentsOf: datesOfMonth())

        return dates
    }
    
}
