import Foundation

// MARK: - Text Comparison Result

/// 텍스트 비교 결과
struct TextComparisonResult: Equatable, Sendable {
    /// 비교 차이점 목록
    let differences: [TextDifference]

    /// 일치 비율 (0.0 ~ 1.0)
    let matchPercentage: Float
}

// MARK: - Text Difference

/// 텍스트 차이점
struct TextDifference: Equatable, Sendable {
    /// 차이 유형
    let type: DifferenceType

    /// 원본 텍스트
    let sourceText: String

    /// 대상 텍스트
    let targetText: String
}

// MARK: - Difference Type

/// 차이 유형
enum DifferenceType: Equatable, Sendable {
    case match          // 일치
    case substitution   // 대체 (다른 단어)
    case insertion      // 삽입 (원문에 없는 단어)
    case deletion       // 삭제 (발음 안 된 단어)
}
