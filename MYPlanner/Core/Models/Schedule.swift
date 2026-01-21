//
//  Schedule.swift
//  MYPlanner
//
//  일정 모델 - SwiftData @Model
//

import Foundation
import SwiftData

@Model
final class Schedule {
    var id: UUID
    var title: String
    var date: Date
    var categoryRaw: String
    var createdAt: Date
    var isGenerating: Bool = false  // AI expression generation in progress

    // One-to-many relationship with cascade delete
    @Relationship(deleteRule: .cascade)
    var expressions: [Expression]

    // Computed property for Category enum
    var category: Category {
        get { Category(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        title: String,
        date: Date = Date(),
        category: Category = .other,
        expressions: [Expression] = [],
        isGenerating: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.categoryRaw = category.rawValue
        self.expressions = expressions
        self.isGenerating = isGenerating
        self.createdAt = createdAt
    }
}

// MARK: - Date Helpers

extension Schedule {
    /// 날짜만 비교 (시간 제외)
    func isSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: otherDate)
    }

    /// 오늘인지 확인
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    /// 포맷된 날짜 문자열
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
}

// MARK: - Query Helpers

extension Schedule {
    /// 특정 날짜의 시작과 끝 범위 생성
    static func dayRange(for date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return (startOfDay, endOfDay)
    }

    /// 날짜 범위로 필터링하는 Predicate 생성
    static func predicate(for date: Date) -> Predicate<Schedule> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return #Predicate<Schedule> { schedule in
            schedule.date >= startOfDay && schedule.date < endOfDay
        }
    }
}
