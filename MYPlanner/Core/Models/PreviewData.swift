//
//  PreviewData.swift
//  MYPlanner
//
//  SwiftUI Preview 및 개발용 Mock 데이터
//  SwiftData ModelContainer를 사용하여 Preview 지원
//

import Foundation
import SwiftData

@MainActor
enum PreviewData {

    // MARK: - Model Container for Previews

    /// Preview용 ModelContainer (샘플 데이터 포함)
    static var container: ModelContainer = {
        let schema = Schema([Schedule.self, Expression.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])

            // Insert sample data
            insertSampleData(into: container.mainContext)

            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()

    /// 빈 Preview용 ModelContainer
    static var emptyContainer: ModelContainer = {
        let schema = Schema([Schedule.self, Expression.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create empty preview container: \(error)")
        }
    }()

    // MARK: - Sample Data Insertion

    private static func insertSampleData(into context: ModelContext) {
        // Create expressions
        let expr1 = Expression(
            english: "Prepare for the product meeting.",
            accent: "pre-PARE for the PRO-duct MEET-ing"
        )
        let expr2 = Expression(
            english: "Get ready for the meeting.",
            accent: "get REA-dy for the MEET-ing"
        )
        let expr3 = Expression(
            english: "Prepare materials for the presentation.",
            accent: "pre-PARE ma-TE-ri-als for the pre-sen-TA-tion"
        )
        let expr4 = Expression(
            english: "I need to fix my car.",
            accent: "I need to FIX my CAR",
            isPracticed: true
        )
        let expr5 = Expression(
            english: "Take the car to the mechanic.",
            accent: "TAKE the CAR to the me-CHA-nic"
        )
        let expr6 = Expression(
            english: "I'm cooking dinner tonight.",
            accent: "I'm COOK-ing DIN-ner to-NIGHT"
        )

        // Create schedules with expressions
        let schedule1 = Schedule(
            title: "회의 준비하기",
            date: Date(),
            category: .meeting,
            expressions: [expr1, expr2, expr3]
        )

        let schedule2 = Schedule(
            title: "자동차 수리",
            date: Date(),
            category: .personal,
            expressions: [expr4, expr5]
        )

        let schedule3 = Schedule(
            title: "저녁 준비하기",
            date: Date(),
            category: .personal,
            expressions: [expr6]
        )

        let schedule4 = Schedule(
            title: "프로젝트 리뷰",
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            category: .work,
            expressions: []
        )

        let schedule5 = Schedule(
            title: "건강검진",
            date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            category: .health,
            expressions: []
        )

        // Insert into context
        context.insert(schedule1)
        context.insert(schedule2)
        context.insert(schedule3)
        context.insert(schedule4)
        context.insert(schedule5)
    }

    // MARK: - Single Items for Preview

    /// Preview용 단일 Schedule
    static var singleSchedule: Schedule {
        let expr1 = Expression(
            english: "Prepare for the product meeting.",
            accent: "pre-PARE for the PRO-duct MEET-ing"
        )
        let expr2 = Expression(
            english: "Get ready for the meeting.",
            accent: "get REA-dy for the MEET-ing"
        )

        return Schedule(
            title: "회의 준비하기",
            date: Date(),
            category: .meeting,
            expressions: [expr1, expr2]
        )
    }

    /// Preview용 단일 Expression
    static var singleExpression: Expression {
        Expression(
            english: "Prepare for the product meeting.",
            accent: "pre-PARE for the PRO-duct MEET-ing"
        )
    }
}
