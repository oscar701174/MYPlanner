//
//  PreviewData.swift
//  MYPlanner
//
//  SwiftUI Preview 및 개발용 Mock 데이터
//

import Foundation

enum PreviewData {
    // MARK: - Expressions

    static let expressions: [Expression] = [
        Expression(
            english: "Prepare for the product meeting.",
            accent: "pre-PARE for the PRO-duct MEET-ing"
        ),
        Expression(
            english: "Get ready for the meeting.",
            accent: "get REA-dy for the MEET-ing"
        ),
        Expression(
            english: "Prepare materials for the presentation.",
            accent: "pre-PARE ma-TE-ri-als for the pre-sen-TA-tion"
        ),
        Expression(
            english: "I need to fix my car.",
            accent: "I need to FIX my CAR",
            isPracticed: true
        ),
        Expression(
            english: "Take the car to the mechanic.",
            accent: "TAKE the CAR to the me-CHA-nic"
        ),
        Expression(
            english: "I'm cooking dinner tonight.",
            accent: "I'm COOK-ing DIN-ner to-NIGHT"
        )
    ]

    // MARK: - Schedules

    static let schedules: [Schedule] = [
        Schedule(
            title: "회의 준비하기",
            date: Date(),
            category: .meeting,
            expressions: Array(expressions[0...2])
        ),
        Schedule(
            title: "자동차 수리",
            date: Date(),
            category: .personal,
            expressions: Array(expressions[3...4])
        ),
        Schedule(
            title: "저녁 준비하기",
            date: Date(),
            category: .personal,
            expressions: [expressions[5]]
        ),
        Schedule(
            title: "프로젝트 리뷰",
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            category: .work,
            expressions: []
        ),
        Schedule(
            title: "건강검진",
            date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            category: .health,
            expressions: []
        )
    ]

    // MARK: - Single Items (for Preview)

    static let singleSchedule = schedules[0]
    static let singleExpression = expressions[0]

    // MARK: - Filtered Data

    /// 오늘 일정만 필터
    static var todaySchedules: [Schedule] {
        schedules.filter { $0.isToday }
    }

    /// 특정 날짜의 일정
    static func schedules(for date: Date) -> [Schedule] {
        schedules.filter { $0.isSameDay(as: date) }
    }

    /// 카테고리별 일정
    static func schedules(for category: Category) -> [Schedule] {
        schedules.filter { $0.category == category }
    }
}
