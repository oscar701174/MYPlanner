import Foundation
@testable import MYPlanner

// MARK: - Mock Pronunciation Evaluator

/// 테스트용 Mock 발음 평가기
final class MockPronunciationEvaluator: PronunciationEvaluating {

    // MARK: - Stub Values

    var stubScore: PronunciationScore?

    // MARK: - Call Tracking

    var evaluateCallCount: Int = 0
    var lastRecognizedResult: SpeechRecognitionResult?
    var lastOriginalText: String?

    // MARK: - Protocol Methods

    func evaluate(recognized: SpeechRecognitionResult, original: String) -> PronunciationScore {
        evaluateCallCount += 1
        lastRecognizedResult = recognized
        lastOriginalText = original

        if let score = stubScore {
            return score
        }

        // 기본 반환값
        return PronunciationScore(overallAccuracy: 0.0, wordResults: [])
    }

    // MARK: - Test Helpers

    /// 상태 초기화
    func reset() {
        evaluateCallCount = 0
        lastRecognizedResult = nil
        lastOriginalText = nil
        stubScore = nil
    }
}
