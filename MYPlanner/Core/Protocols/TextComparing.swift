import Foundation

// MARK: - Text Comparing Protocol

/// 텍스트 비교 책임 (SRP: 오직 비교/Diff만)
protocol TextComparing {
    /// 두 텍스트 비교
    /// - Parameters:
    ///   - source: 원본 텍스트
    ///   - target: 비교 대상 텍스트
    /// - Returns: 비교 결과
    func compare(source: String, target: String) -> TextComparisonResult
}
