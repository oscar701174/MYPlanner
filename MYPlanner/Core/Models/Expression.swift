//
//  Expression.swift
//  MYPlanner
//
//  영어 표현 모델 - SwiftData @Model
//

import Foundation
import SwiftData

@Model
final class Expression: Identifiable {
    var id: UUID
    var english: String
    var accent: String  // "pre-PARE for the PRO-duct MEET-ing"
    var isPracticed: Bool
    var isFavorite: Bool
    var createdAt: Date

    /// 연습 기록 목록 (최신순)
    @Relationship(deleteRule: .cascade, inverse: \PracticeRecord.expression)
    var practiceRecords: [PracticeRecord] = []

    init(
        id: UUID = UUID(),
        english: String,
        accent: String? = nil,
        isPracticed: Bool = false,
        isFavorite: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.english = english
        // Auto-generate accent using CMU Dictionary if not provided
        self.accent = accent ?? AccentFormatter.shared.format(english)
        self.isPracticed = isPracticed
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }
}

// MARK: - Practice Record Helpers

extension Expression {
    /// 연습 기록이 있는지 확인 (안전한 접근)
    var hasPracticeRecords: Bool {
        !practiceRecords.isEmpty
    }

    /// 가장 최근 연습 기록 (캐시된 배열 사용)
    var lastPracticeRecord: PracticeRecord? {
        guard hasPracticeRecords else { return nil }
        let records: [PracticeRecord] = Array(practiceRecords)
        return records.max { $0.practicedAt < $1.practicedAt }
    }

    /// 최고 점수 기록
    var bestPracticeRecord: PracticeRecord? {
        guard hasPracticeRecords else { return nil }
        let records: [PracticeRecord] = Array(practiceRecords)
        return records.max { $0.overallAccuracy < $1.overallAccuracy }
    }

    /// 연습 횟수
    var practiceCount: Int {
        practiceRecords.count
    }

    /// 평균 점수
    var averageAccuracy: Float? {
        guard hasPracticeRecords else { return nil }
        let records: [PracticeRecord] = Array(practiceRecords)
        let total: Float = records.reduce(0) { $0 + $1.overallAccuracy }
        return total / Float(records.count)
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
