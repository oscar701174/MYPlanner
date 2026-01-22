import Foundation

// MARK: - Pronunciation Evaluator

/// 발음 평가 구현체
final class PronunciationEvaluator: PronunciationEvaluating {

    // MARK: - Dependencies

    private let textComparator: TextComparing

    // MARK: - Initialization

    init(textComparator: TextComparing = TextComparator()) {
        self.textComparator = textComparator
    }

    // MARK: - Public Methods

    func evaluate(recognized: SpeechRecognitionResult, original: String) -> PronunciationScore {
        // 1. 텍스트 비교
        let comparison: TextComparisonResult = textComparator.compare(
            source: original,
            target: recognized.text
        )

        // 2. 단어별 결과 생성
        let wordResults: [WordResult] = generateWordResults(
            from: comparison,
            segments: recognized.segments
        )

        // 3. 최종 점수 계산
        let overallAccuracy: Float = calculateOverallAccuracy(
            comparison: comparison,
            segments: recognized.segments,
            overallConfidence: recognized.confidence
        )

        return PronunciationScore(
            overallAccuracy: overallAccuracy,
            wordResults: wordResults
        )
    }

    // MARK: - Private Methods

    /// 단어별 결과 생성
    private func generateWordResults(
        from comparison: TextComparisonResult,
        segments: [SpeechSegment]
    ) -> [WordResult] {
        var results: [WordResult] = []
        var segmentIndex: Int = 0

        for difference in comparison.differences {
            let confidence: Float = getConfidence(
                for: difference.targetText,
                segments: segments,
                currentIndex: &segmentIndex
            )

            let status: WordStatus = mapDifferenceToStatus(difference.type)

            let result: WordResult = WordResult(
                originalWord: difference.sourceText,
                recognizedWord: difference.targetText.isEmpty ? nil : difference.targetText,
                confidence: confidence,
                status: status
            )

            results.append(result)
        }

        return results
    }

    /// DifferenceType을 WordStatus로 변환
    private func mapDifferenceToStatus(_ type: DifferenceType) -> WordStatus {
        switch type {
        case .match:
            return .correct
        case .substitution:
            return .mispronounced
        case .deletion:
            return .missing
        case .insertion:
            return .extra
        }
    }

    /// 특정 단어의 confidence 값 가져오기
    private func getConfidence(
        for word: String,
        segments: [SpeechSegment],
        currentIndex: inout Int
    ) -> Float {
        guard !word.isEmpty else { return 0.0 }
        guard currentIndex < segments.count else { return 0.5 }

        let normalizedWord: String = word.lowercased()

        // 현재 인덱스부터 매칭되는 segment 찾기
        for i in currentIndex..<segments.count {
            if segments[i].text.lowercased() == normalizedWord {
                currentIndex = i + 1
                return segments[i].confidence
            }
        }

        // 매칭 실패 시 기본값
        return 0.5
    }

    /// 전체 정확도 계산
    /// - 텍스트 일치율과 confidence를 결합
    private func calculateOverallAccuracy(
        comparison: TextComparisonResult,
        segments: [SpeechSegment],
        overallConfidence: Float
    ) -> Float {
        // 텍스트 일치율
        let textMatchScore: Float = comparison.matchPercentage

        // segment confidence 평균 (있는 경우)
        let avgConfidence: Float
        if segments.isEmpty {
            avgConfidence = overallConfidence
        } else {
            let totalConfidence: Float = segments.reduce(0) { $0 + $1.confidence }
            avgConfidence = totalConfidence / Float(segments.count)
        }

        // 가중 평균 (텍스트 일치 60%, confidence 40%)
        let weightedScore: Float = (textMatchScore * 0.6) + (avgConfidence * 0.4)

        // 텍스트가 완전히 일치하지 않으면 최대 점수 제한
        if textMatchScore < 1.0 {
            return min(weightedScore, textMatchScore + 0.1)
        }

        return weightedScore
    }
}
