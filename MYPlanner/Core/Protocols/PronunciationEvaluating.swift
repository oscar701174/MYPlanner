import Foundation

// MARK: - Pronunciation Evaluating Protocol

/// 발음 평가 책임 (SRP: 오직 평가 로직만)
protocol PronunciationEvaluating {
    /// 발음 평가 실행
    /// - Parameters:
    ///   - recognized: 음성 인식 결과
    ///   - original: 원본 텍스트
    /// - Returns: 발음 점수
    func evaluate(recognized: SpeechRecognitionResult, original: String) -> PronunciationScore
}
