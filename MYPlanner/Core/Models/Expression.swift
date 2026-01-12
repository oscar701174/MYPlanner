//
//  Expression.swift
//  MYPlanner
//
//  영어 표현 모델 (Mock용 struct, Step 8에서 @Model로 변환)
//

import Foundation

struct Expression: Identifiable, Equatable, Hashable {
    let id: UUID
    var english: String
    var accent: String  // "pre-PARE for the PRO-duct MEET-ing"
    var isPracticed: Bool

    init(
        id: UUID = UUID(),
        english: String,
        accent: String = "",
        isPracticed: Bool = false
    ) {
        self.id = id
        self.english = english
        self.accent = accent.isEmpty ? english : accent
        self.isPracticed = isPracticed
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
