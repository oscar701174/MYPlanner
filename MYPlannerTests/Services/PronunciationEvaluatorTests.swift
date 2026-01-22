import XCTest
@testable import MYPlanner

@MainActor
final class PronunciationEvaluatorTests: XCTestCase {

    var sut: PronunciationEvaluator!
    var mockTextComparator: MockTextComparator!

    override func setUp() {
        super.setUp()
        mockTextComparator = MockTextComparator()
        sut = PronunciationEvaluator(textComparator: mockTextComparator)
    }

    override func tearDown() {
        sut = nil
        mockTextComparator = nil
        super.tearDown()
    }

    // MARK: - Basic Evaluation Tests

    func test_evaluate_perfectPronunciation_returnsExcellentGrade() {
        // Given
        mockTextComparator.stubResult = TextComparisonResult(
            differences: [
                TextDifference(type: .match, sourceText: "hello", targetText: "hello")
            ],
            matchPercentage: 1.0
        )

        let recognitionResult: SpeechRecognitionResult = SpeechRecognitionResult(
            text: "hello",
            isFinal: true,
            segments: [
                SpeechSegment(text: "hello", confidence: 0.95, timestamp: 0.0, duration: 0.5)
            ],
            confidence: 0.95
        )

        // When
        let score: PronunciationScore = sut.evaluate(recognized: recognitionResult, original: "hello")

        // Then
        XCTAssertEqual(score.grade, .excellent)
        XCTAssertGreaterThanOrEqual(score.overallAccuracy, 0.9)
    }

    func test_evaluate_partialMatch_calculatesCorrectScore() {
        // Given
        mockTextComparator.stubResult = TextComparisonResult(
            differences: [
                TextDifference(type: .match, sourceText: "i", targetText: "i"),
                TextDifference(type: .substitution, sourceText: "am", targetText: "an"),
                TextDifference(type: .match, sourceText: "a", targetText: "a"),
                TextDifference(type: .substitution, sourceText: "boy", targetText: "poy")
            ],
            matchPercentage: 0.5
        )

        let recognitionResult: SpeechRecognitionResult = SpeechRecognitionResult(
            text: "I an a poy",
            isFinal: true,
            segments: [
                SpeechSegment(text: "I", confidence: 0.9, timestamp: 0.0, duration: 0.2),
                SpeechSegment(text: "an", confidence: 0.6, timestamp: 0.2, duration: 0.2),
                SpeechSegment(text: "a", confidence: 0.95, timestamp: 0.4, duration: 0.1),
                SpeechSegment(text: "poy", confidence: 0.5, timestamp: 0.5, duration: 0.3)
            ],
            confidence: 0.7
        )

        // When
        let score: PronunciationScore = sut.evaluate(recognized: recognitionResult, original: "I am a boy")

        // Then
        XCTAssertEqual(score.grade, .fair)
        XCTAssertLessThan(score.overallAccuracy, 0.7)
    }

    func test_evaluate_callsTextComparator() {
        // Given
        let recognitionResult: SpeechRecognitionResult = SpeechRecognitionResult(
            text: "hello",
            isFinal: true,
            segments: [],
            confidence: 0.9
        )

        // When
        _ = sut.evaluate(recognized: recognitionResult, original: "hello")

        // Then
        XCTAssertEqual(mockTextComparator.compareCallCount, 1)
        XCTAssertEqual(mockTextComparator.lastSourceText, "hello")
        XCTAssertEqual(mockTextComparator.lastTargetText, "hello")
    }

    // MARK: - Word Result Tests

    func test_evaluate_generatesWordResults() {
        // Given
        mockTextComparator.stubResult = TextComparisonResult(
            differences: [
                TextDifference(type: .match, sourceText: "hello", targetText: "hello"),
                TextDifference(type: .substitution, sourceText: "world", targetText: "word")
            ],
            matchPercentage: 0.5
        )

        let recognitionResult: SpeechRecognitionResult = SpeechRecognitionResult(
            text: "hello word",
            isFinal: true,
            segments: [
                SpeechSegment(text: "hello", confidence: 0.9, timestamp: 0.0, duration: 0.3),
                SpeechSegment(text: "word", confidence: 0.7, timestamp: 0.3, duration: 0.3)
            ],
            confidence: 0.8
        )

        // When
        let score: PronunciationScore = sut.evaluate(recognized: recognitionResult, original: "hello world")

        // Then
        XCTAssertEqual(score.wordResults.count, 2)

        let firstWord: WordResult? = score.wordResults.first
        XCTAssertEqual(firstWord?.originalWord, "hello")
        XCTAssertEqual(firstWord?.status, .correct)

        let secondWord: WordResult? = score.wordResults.last
        XCTAssertEqual(secondWord?.originalWord, "world")
        XCTAssertEqual(secondWord?.status, .mispronounced)
    }

    func test_evaluate_detectsMissingWord() {
        // Given
        mockTextComparator.stubResult = TextComparisonResult(
            differences: [
                TextDifference(type: .match, sourceText: "hello", targetText: "hello"),
                TextDifference(type: .deletion, sourceText: "beautiful", targetText: ""),
                TextDifference(type: .match, sourceText: "world", targetText: "world")
            ],
            matchPercentage: 0.67
        )

        let recognitionResult: SpeechRecognitionResult = SpeechRecognitionResult(
            text: "hello world",
            isFinal: true,
            segments: [],
            confidence: 0.8
        )

        // When
        let score: PronunciationScore = sut.evaluate(
            recognized: recognitionResult,
            original: "hello beautiful world"
        )

        // Then
        let missingWords: [WordResult] = score.wordResults.filter { $0.status == .missing }
        XCTAssertEqual(missingWords.count, 1)
        XCTAssertEqual(missingWords.first?.originalWord, "beautiful")
    }

    func test_evaluate_detectsExtraWord() {
        // Given
        mockTextComparator.stubResult = TextComparisonResult(
            differences: [
                TextDifference(type: .match, sourceText: "hello", targetText: "hello"),
                TextDifference(type: .insertion, sourceText: "", targetText: "um"),
                TextDifference(type: .match, sourceText: "world", targetText: "world")
            ],
            matchPercentage: 0.67
        )

        let recognitionResult: SpeechRecognitionResult = SpeechRecognitionResult(
            text: "hello um world",
            isFinal: true,
            segments: [],
            confidence: 0.8
        )

        // When
        let score: PronunciationScore = sut.evaluate(recognized: recognitionResult, original: "hello world")

        // Then
        let extraWords: [WordResult] = score.wordResults.filter { $0.status == .extra }
        XCTAssertEqual(extraWords.count, 1)
        XCTAssertEqual(extraWords.first?.recognizedWord, "um")
    }

    // MARK: - Confidence Tests

    func test_evaluate_usesSegmentConfidence() {
        // Given
        mockTextComparator.stubResult = TextComparisonResult(
            differences: [
                TextDifference(type: .match, sourceText: "hello", targetText: "hello")
            ],
            matchPercentage: 1.0
        )

        let recognitionResult: SpeechRecognitionResult = SpeechRecognitionResult(
            text: "hello",
            isFinal: true,
            segments: [
                SpeechSegment(text: "hello", confidence: 0.5, timestamp: 0.0, duration: 0.5)
            ],
            confidence: 0.5
        )

        // When
        let score: PronunciationScore = sut.evaluate(recognized: recognitionResult, original: "hello")

        // Then
        // 텍스트는 일치하지만 confidence가 낮으므로 점수가 낮아짐
        XCTAssertLessThan(score.overallAccuracy, 1.0)
    }

    // MARK: - Real Sentence Tests

    func test_evaluate_realSentence_prepareForMeeting() {
        // Given - 실제 TextComparator 사용
        let realComparator: TextComparator = TextComparator()
        let evaluator: PronunciationEvaluator = PronunciationEvaluator(textComparator: realComparator)

        let recognitionResult: SpeechRecognitionResult = SpeechRecognitionResult(
            text: "Prepare for the meeting",
            isFinal: true,
            segments: [
                SpeechSegment(text: "Prepare", confidence: 0.9, timestamp: 0.0, duration: 0.4),
                SpeechSegment(text: "for", confidence: 0.95, timestamp: 0.4, duration: 0.2),
                SpeechSegment(text: "the", confidence: 0.98, timestamp: 0.6, duration: 0.1),
                SpeechSegment(text: "meeting", confidence: 0.92, timestamp: 0.7, duration: 0.4)
            ],
            confidence: 0.94
        )

        // When
        let score: PronunciationScore = evaluator.evaluate(
            recognized: recognitionResult,
            original: "Prepare for the meeting"
        )

        // Then
        XCTAssertEqual(score.grade, .excellent)
        XCTAssertEqual(score.wordResults.count, 4)
        XCTAssertTrue(score.wordResults.allSatisfy { $0.status == .correct })
    }
}
