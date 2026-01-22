import Foundation
@testable import MYPlanner

// MARK: - Mock Text Comparator

/// 테스트용 Mock 텍스트 비교기
final class MockTextComparator: TextComparing {

    // MARK: - Stub Values

    var stubResult: TextComparisonResult?

    // MARK: - Call Tracking

    var compareCallCount: Int = 0
    var lastSourceText: String?
    var lastTargetText: String?

    // MARK: - Protocol Methods

    func compare(source: String, target: String) -> TextComparisonResult {
        compareCallCount += 1
        lastSourceText = source
        lastTargetText = target

        if let result = stubResult {
            return result
        }

        // 기본 반환값 (100% 일치)
        return TextComparisonResult(differences: [], matchPercentage: 1.0)
    }

    // MARK: - Test Helpers

    /// 상태 초기화
    func reset() {
        compareCallCount = 0
        lastSourceText = nil
        lastTargetText = nil
        stubResult = nil
    }
}
