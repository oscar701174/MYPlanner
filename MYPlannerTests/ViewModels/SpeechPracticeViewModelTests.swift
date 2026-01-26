import XCTest
@testable import MYPlanner

@MainActor
final class SpeechPracticeViewModelTests: XCTestCase {

    var sut: SpeechPracticeViewModel!
    var mockRecognizer: MockSpeechRecognizer!
    var mockEvaluator: MockPronunciationEvaluator!

    override func setUp() async throws {
        try await super.setUp()
        mockRecognizer = MockSpeechRecognizer()
        mockEvaluator = MockPronunciationEvaluator()
        sut = SpeechPracticeViewModel(
            speechRecognizer: mockRecognizer,
            evaluator: mockEvaluator
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockRecognizer = nil
        mockEvaluator = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func test_initialState_isIdle() {
        XCTAssertEqual(sut.state, .idle)
    }

    func test_initialState_hasNoError() {
        XCTAssertNil(sut.error)
    }

    func test_initialState_hasNoScore() {
        XCTAssertNil(sut.score)
    }

    // MARK: - Authorization Tests

    func test_checkAuthorization_whenAuthorized_returnsTrue() async {
        mockRecognizer.stubAuthorizationStatus = .authorized

        let isAuthorized: Bool = await sut.checkAuthorization()

        XCTAssertTrue(isAuthorized)
    }

    func test_checkAuthorization_whenDenied_returnsFalse() async {
        mockRecognizer.stubAuthorizationStatus = .denied

        let isAuthorized: Bool = await sut.checkAuthorization()

        XCTAssertFalse(isAuthorized)
    }

    func test_checkAuthorization_whenNotDetermined_requestsAuthorization() async {
        mockRecognizer.stubAuthorizationStatus = .notDetermined

        _ = await sut.checkAuthorization()

        XCTAssertEqual(mockRecognizer.requestAuthorizationCallCount, 1)
    }

    // MARK: - Start Practice Tests

    func test_startPractice_setsStateToRecording() async {
        mockRecognizer.stubAuthorizationStatus = .authorized

        await sut.startPractice(for: "hello")

        XCTAssertEqual(sut.state, .recording)
    }

    func test_startPractice_startsRecognition() async {
        mockRecognizer.stubAuthorizationStatus = .authorized

        await sut.startPractice(for: "hello")

        XCTAssertEqual(mockRecognizer.startRecognitionCallCount, 1)
    }

    func test_startPractice_whenNotAuthorized_setsErrorState() async {
        mockRecognizer.stubAuthorizationStatus = .denied

        await sut.startPractice(for: "hello")

        XCTAssertEqual(sut.state, .error)
        XCTAssertNotNil(sut.error)
    }

    func test_startPractice_storesOriginalText() async {
        mockRecognizer.stubAuthorizationStatus = .authorized

        await sut.startPractice(for: "Prepare for the meeting")

        XCTAssertEqual(sut.originalText, "Prepare for the meeting")
    }

    // MARK: - Stop Practice Tests

    func test_stopPractice_stopsRecognition() async {
        mockRecognizer.stubAuthorizationStatus = .authorized
        await sut.startPractice(for: "hello")

        sut.stopPractice()

        XCTAssertEqual(mockRecognizer.stopRecognitionCallCount, 1)
    }

    func test_stopPractice_setsStateToEvaluating() async {
        mockRecognizer.stubAuthorizationStatus = .authorized
        await sut.startPractice(for: "hello")
        sut.recognizedText = "hello"

        sut.stopPractice()

        XCTAssertEqual(sut.state, .evaluating)
    }

    // MARK: - Evaluation Tests

    func test_evaluate_callsEvaluator() async {
        mockRecognizer.stubAuthorizationStatus = .authorized
        mockEvaluator.stubScore = PronunciationScore(
            overallAccuracy: 0.9,
            wordResults: []
        )

        await sut.startPractice(for: "hello")
        sut.recognizedText = "hello"
        sut.stopPractice()

        // 평가 완료 대기
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockEvaluator.evaluateCallCount, 1)
    }

    func test_evaluate_setsScoreOnCompletion() async {
        mockRecognizer.stubAuthorizationStatus = .authorized
        let expectedScore: PronunciationScore = PronunciationScore(
            overallAccuracy: 0.85,
            wordResults: []
        )
        mockEvaluator.stubScore = expectedScore

        await sut.startPractice(for: "hello")
        sut.recognizedText = "hello"
        sut.stopPractice()

        // 평가 완료 대기
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(sut.score?.overallAccuracy, expectedScore.overallAccuracy)
        XCTAssertEqual(sut.state, .result)
    }

    // MARK: - Reset Tests

    func test_reset_clearsState() async {
        mockRecognizer.stubAuthorizationStatus = .authorized
        mockEvaluator.stubScore = PronunciationScore(overallAccuracy: 0.9, wordResults: [])

        await sut.startPractice(for: "hello")
        sut.recognizedText = "hello"
        sut.stopPractice()

        // 평가 완료 대기
        try? await Task.sleep(nanoseconds: 100_000_000)

        sut.reset()

        XCTAssertEqual(sut.state, .idle)
        XCTAssertNil(sut.score)
        XCTAssertTrue(sut.recognizedText.isEmpty)
        XCTAssertNil(sut.error)
    }

    // MARK: - State Enum Tests

    func test_practiceState_allCases() {
        let allCases: [SpeechPracticeState] = [.idle, .loading, .recording, .evaluating, .result, .error]
        XCTAssertEqual(allCases.count, 6)
    }

    // MARK: - Engine Selection Tests

    func test_init_defaultEngineType_isApple() {
        let viewModel: SpeechPracticeViewModel = SpeechPracticeViewModel(
            speechRecognizer: mockRecognizer,
            evaluator: mockEvaluator
        )

        XCTAssertEqual(viewModel.currentEngineType, .apple)
    }

    func test_init_withWhisperEngine_setsEngineType() {
        let viewModel: SpeechPracticeViewModel = SpeechPracticeViewModel(
            speechRecognizer: mockRecognizer,
            evaluator: mockEvaluator,
            engineType: .whisper
        )

        XCTAssertEqual(viewModel.currentEngineType, .whisper)
    }

    func test_switchEngine_changesEngineType() {
        sut.switchEngine(to: .whisper)

        XCTAssertEqual(sut.currentEngineType, .whisper)
    }

    func test_switchEngine_toSameEngine_doesNothing() {
        sut.switchEngine(to: .apple)

        // 아무 변화 없어야 함
        XCTAssertEqual(sut.currentEngineType, .apple)
        XCTAssertEqual(sut.state, .idle)
    }

    func test_switchEngine_whileRecording_stopsRecognitionFirst() async {
        mockRecognizer.stubAuthorizationStatus = .authorized
        await sut.startPractice(for: "hello")

        XCTAssertEqual(sut.state, .recording)

        sut.switchEngine(to: .whisper)

        XCTAssertEqual(mockRecognizer.stopRecognitionCallCount, 1)
        XCTAssertEqual(sut.state, .idle)
    }

    func test_switchEngine_resetsState() async {
        mockRecognizer.stubAuthorizationStatus = .authorized
        mockEvaluator.stubScore = PronunciationScore(overallAccuracy: 0.9, wordResults: [])

        await sut.startPractice(for: "hello")
        sut.recognizedText = "hello"
        sut.stopPractice()

        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.state, .result)

        sut.switchEngine(to: .whisper)

        XCTAssertEqual(sut.state, .idle)
        XCTAssertNil(sut.score)
        XCTAssertTrue(sut.recognizedText.isEmpty)
    }

    // MARK: - Engine Type Tests

    func test_engineType_displayName() {
        XCTAssertEqual(SpeechRecognitionEngineType.apple.displayName, "Apple Speech")
        XCTAssertEqual(SpeechRecognitionEngineType.whisper.displayName, "Whisper (On-device)")
    }

    func test_engineType_iconName() {
        XCTAssertEqual(SpeechRecognitionEngineType.apple.iconName, "apple.logo")
        XCTAssertEqual(SpeechRecognitionEngineType.whisper.iconName, "waveform.badge.mic")
    }

    func test_engineType_allCases() {
        XCTAssertEqual(SpeechRecognitionEngineType.allCases.count, 2)
    }
}
