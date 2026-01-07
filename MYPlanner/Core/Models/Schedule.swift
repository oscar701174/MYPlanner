//
//  Schedule.swift
//  MYPlanner
//
//  일정 모델 (Mock용 struct, Step 8에서 @Model로 변환)
//

import Foundation

struct Schedule: Identifiable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var category: Category
    var expressions: [Expression]
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        date: Date = Date(),
        category: Category = .other,
        expressions: [Expression] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.category = category
        self.expressions = expressions
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
