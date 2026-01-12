//
//  Expression.swift
//  MYPlanner
//
//  영어 표현 모델 - SwiftData @Model
//

import Foundation
import SwiftData

@Model
final class Expression {
    var id: UUID
    var english: String
    var accent: String  // "pre-PARE for the PRO-duct MEET-ing"
    var isPracticed: Bool
    var createdAt: Date

    // Inverse relationship to Schedule
    var schedule: Schedule?

    init(
        id: UUID = UUID(),
        english: String,
        accent: String = "",
        isPracticed: Bool = false,
        createdAt: Date = Date(),
        schedule: Schedule? = nil
    ) {
        self.id = id
        self.english = english
        self.accent = accent.isEmpty ? english : accent
        self.isPracticed = isPracticed
        self.createdAt = createdAt
        self.schedule = schedule
    }
}

// MARK: - Accent Helpers

extension Expression {
    /// 악센트가 있는지 확인
    var hasAccent: Bool {
        accent.contains(where: { $0.isUppercase })
    }

    /// 강세 음절 개수
    var stressedSyllableCount: Int {
        accent
            .split(separator: " ")
            .flatMap { $0.split(separator: "-") }
            .filter { $0.allSatisfy { $0.isUppercase || !$0.isLetter } }
            .count
    }
}
