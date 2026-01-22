import XCTest
@testable import MYPlanner

@MainActor
final class PronunciationScoreTests: XCTestCase {

    // MARK: - Grade Tests

    func test_grade_95percent_returnsExcellent() {
        let score: PronunciationScore = PronunciationScore(overallAccuracy: 0.95, wordResults: [])
        XCTAssertEqual(score.grade, .excellent)
    }

    func test_grade_90percent_returnsExcellent() {
        let score: PronunciationScore = PronunciationScore(overallAccuracy: 0.90, wordResults: [])
        XCTAssertEqual(score.grade, .excellent)
    }

    func test_grade_89percent_returnsGood() {
        let score: PronunciationScore = PronunciationScore(overallAccuracy: 0.89, wordResults: [])
        XCTAssertEqual(score.grade, .good)
    }

    func test_grade_70percent_returnsGood() {
        let score: PronunciationScore = PronunciationScore(overallAccuracy: 0.70, wordResults: [])
        XCTAssertEqual(score.grade, .good)
    }

    func test_grade_69percent_returnsFair() {
        let score: PronunciationScore = PronunciationScore(overallAccuracy: 0.69, wordResults: [])
        XCTAssertEqual(score.grade, .fair)
    }

    func test_grade_50percent_returnsFair() {
        let score: PronunciationScore = PronunciationScore(overallAccuracy: 0.50, wordResults: [])
        XCTAssertEqual(score.grade, .fair)
    }

    func test_grade_49percent_returnsNeedsPractice() {
        let score: PronunciationScore = PronunciationScore(overallAccuracy: 0.49, wordResults: [])
        XCTAssertEqual(score.grade, .needsPractice)
    }

    func test_grade_0percent_returnsNeedsPractice() {
        let score: PronunciationScore = PronunciationScore(overallAccuracy: 0.0, wordResults: [])
        XCTAssertEqual(score.grade, .needsPractice)
    }

    // MARK: - Grade Properties Tests

    func test_excellentGrade_hasCorrectEmoji() {
        XCTAssertEqual(PronunciationGrade.excellent.emoji, "🌟")
    }

    func test_goodGrade_hasCorrectEmoji() {
        XCTAssertEqual(PronunciationGrade.good.emoji, "👍")
    }

    func test_fairGrade_hasCorrectEmoji() {
        XCTAssertEqual(PronunciationGrade.fair.emoji, "💪")
    }

    func test_needsPracticeGrade_hasCorrectEmoji() {
        XCTAssertEqual(PronunciationGrade.needsPractice.emoji, "📚")
    }

    func test_excellentGrade_hasCorrectMessage() {
        XCTAssertEqual(PronunciationGrade.excellent.message, "Excellent!")
    }

    func test_goodGrade_hasCorrectMessage() {
        XCTAssertEqual(PronunciationGrade.good.message, "Good job!")
    }

    func test_fairGrade_hasCorrectMessage() {
        XCTAssertEqual(PronunciationGrade.fair.message, "Keep practicing!")
    }

    func test_needsPracticeGrade_hasCorrectMessage() {
        XCTAssertEqual(PronunciationGrade.needsPractice.message, "Try again!")
    }
}

// MARK: - WordResult Tests

@MainActor
final class WordResultTests: XCTestCase {

    func test_wordResult_correctStatus_whenMatched() {
        let result: WordResult = WordResult(
            originalWord: "hello",
            recognizedWord: "hello",
            confidence: 0.95,
            status: .correct
        )
        XCTAssertEqual(result.status, .correct)
        XCTAssertEqual(result.originalWord, result.recognizedWord)
    }

    func test_wordResult_mispronounced_whenDifferent() {
        let result: WordResult = WordResult(
            originalWord: "hello",
            recognizedWord: "hallo",
            confidence: 0.60,
            status: .mispronounced
        )
        XCTAssertEqual(result.status, .mispronounced)
        XCTAssertNotEqual(result.originalWord, result.recognizedWord)
    }

    func test_wordResult_missing_whenNotRecognized() {
        let result: WordResult = WordResult(
            originalWord: "hello",
            recognizedWord: nil,
            confidence: 0.0,
            status: .missing
        )
        XCTAssertEqual(result.status, .missing)
        XCTAssertNil(result.recognizedWord)
    }

    func test_wordResult_extra_whenUnexpected() {
        let result: WordResult = WordResult(
            originalWord: "",
            recognizedWord: "um",
            confidence: 0.80,
            status: .extra
        )
        XCTAssertEqual(result.status, .extra)
    }
}

// MARK: - WordStatus Tests

@MainActor
final class WordStatusTests: XCTestCase {

    func test_wordStatus_allCases() {
        let allCases: [WordStatus] = [.correct, .mispronounced, .missing, .extra]
        XCTAssertEqual(allCases.count, 4)
    }
}

// MARK: - SpeechRecognitionResult Tests

@MainActor
final class SpeechRecognitionResultTests: XCTestCase {

    func test_speechRecognitionResult_initialization() {
        let segments: [SpeechSegment] = [
            SpeechSegment(text: "hello", confidence: 0.95, timestamp: 0.0, duration: 0.5)
        ]
        let result: SpeechRecognitionResult = SpeechRecognitionResult(
            text: "hello",
            isFinal: true,
            segments: segments,
            confidence: 0.95
        )

        XCTAssertEqual(result.text, "hello")
        XCTAssertTrue(result.isFinal)
        XCTAssertEqual(result.segments.count, 1)
        XCTAssertEqual(result.confidence, 0.95)
    }

    func test_speechSegment_initialization() {
        let segment: SpeechSegment = SpeechSegment(
            text: "world",
            confidence: 0.88,
            timestamp: 0.5,
            duration: 0.3
        )

        XCTAssertEqual(segment.text, "world")
        XCTAssertEqual(segment.confidence, 0.88)
        XCTAssertEqual(segment.timestamp, 0.5)
        XCTAssertEqual(segment.duration, 0.3)
    }
}

// MARK: - SpeechAuthorizationStatus Tests

@MainActor
final class SpeechAuthorizationStatusTests: XCTestCase {

    func test_authorizationStatus_allCases() {
        let allCases: [SpeechAuthorizationStatus] = [
            .notDetermined,
            .denied,
            .restricted,
            .authorized
        ]
        XCTAssertEqual(allCases.count, 4)
    }
}
