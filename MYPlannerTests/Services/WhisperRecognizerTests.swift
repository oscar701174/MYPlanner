import XCTest
import AVFoundation
@testable import MYPlanner

/// WhisperRecognizer 테스트
/// TDD Phase: WhisperKit 기반 음성 인식 테스트
@MainActor
final class WhisperRecognizerTests: XCTestCase {

    var sut: WhisperRecognizer!
    var mockAudioSession: MockAudioSessionManager!

    override func setUp() async throws {
        try await super.setUp()
        mockAudioSession = MockAudioSessionManager()
        sut = WhisperRecognizer(
            modelName: "openai_whisper-base.en",
            audioSession: mockAudioSession
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockAudioSession = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func test_init_isRecognizingIsFalse() {
        XCTAssertFalse(sut.isRecognizing)
    }

    func test_init_authorizationStatus_dependsOnMicPermission() {
        // WhisperKit은 마이크 권한만 필요
        // 실제 디바이스에서는 AVAudioApplication.shared.recordPermission에 따라 결정됨
        // 시뮬레이터에서는 .notDetermined 또는 .granted
        let status: SpeechAuthorizationStatus = sut.authorizationStatus
        XCTAssertTrue([.notDetermined, .authorized, .denied].contains(status))
    }

    // MARK: - Authorization Tests

    func test_requestAuthorization_returnsStatus() async {
        // Note: 실제 권한 요청은 시스템 다이얼로그를 표시하므로
        // 테스트에서는 반환값만 확인
        let status: SpeechAuthorizationStatus = await sut.requestAuthorization()
        XCTAssertTrue([.notDetermined, .authorized, .denied, .restricted].contains(status))
    }

    // MARK: - Start Recognition Tests

    func test_startRecognition_whenNotAuthorized_throwsNotAuthorized() async {
        // WhisperRecognizer가 마이크 권한이 없을 때
        // 이 테스트는 authorizationStatus가 .denied일 때만 실패해야 함
        // 테스트 환경에서는 권한이 granted일 수 있으므로 조건부 테스트
        if sut.authorizationStatus != .authorized {
            do {
                try await sut.startRecognition()
                XCTFail("Expected notAuthorized error")
            } catch let error as SpeechRecognitionError {
                XCTAssertEqual(error, .notAuthorized)
            } catch {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }

    func test_startRecognition_configuresAudioSession() async throws {
        // 권한이 있는 경우에만 테스트 실행
        guard sut.authorizationStatus == .authorized else {
            throw XCTSkip("Microphone permission required for this test")
        }

        do {
            try await sut.startRecognition()
            XCTAssertEqual(mockAudioSession.configureForRecordingCallCount, 1)
            sut.stopRecognition()
        } catch SpeechRecognitionError.notAvailable {
            // WhisperKit 모델 로딩 실패는 CI 환경에서 예상됨
            throw XCTSkip("WhisperKit model not available in test environment")
        }
    }

    func test_startRecognition_setsIsRecognizingTrue() async throws {
        guard sut.authorizationStatus == .authorized else {
            throw XCTSkip("Microphone permission required for this test")
        }

        do {
            try await sut.startRecognition()
            XCTAssertTrue(sut.isRecognizing)
            sut.stopRecognition()
        } catch SpeechRecognitionError.notAvailable {
            throw XCTSkip("WhisperKit model not available in test environment")
        }
    }

    func test_startRecognition_whenAudioSessionFails_throwsAudioEngineError() async throws {
        guard sut.authorizationStatus == .authorized else {
            throw XCTSkip("Microphone permission required for this test")
        }

        mockAudioSession.stubError = .configurationFailed

        do {
            try await sut.startRecognition()
            XCTFail("Expected audioEngineError")
        } catch let error as SpeechRecognitionError {
            XCTAssertEqual(error, .audioEngineError)
        } catch SpeechRecognitionError.notAvailable {
            throw XCTSkip("WhisperKit model not available in test environment")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Stop Recognition Tests

    func test_stopRecognition_setsIsRecognizingFalse() async throws {
        guard sut.authorizationStatus == .authorized else {
            throw XCTSkip("Microphone permission required for this test")
        }

        do {
            try await sut.startRecognition()
            sut.stopRecognition()
            XCTAssertFalse(sut.isRecognizing)
        } catch SpeechRecognitionError.notAvailable {
            throw XCTSkip("WhisperKit model not available in test environment")
        }
    }

    func test_stopRecognition_deactivatesAudioSession() async throws {
        guard sut.authorizationStatus == .authorized else {
            throw XCTSkip("Microphone permission required for this test")
        }

        do {
            try await sut.startRecognition()
            sut.stopRecognition()

            // 비동기 정리 대기
            try? await Task.sleep(nanoseconds: 100_000_000)

            XCTAssertEqual(mockAudioSession.deactivateCallCount, 1)
        } catch SpeechRecognitionError.notAvailable {
            throw XCTSkip("WhisperKit model not available in test environment")
        }
    }

    // MARK: - Recognition Results Stream Tests

    func test_recognitionResults_returnsAsyncStream() {
        let stream: AsyncStream<SpeechRecognitionResult> = sut.recognitionResults
        XCTAssertNotNil(stream)
    }

    // MARK: - Model Configuration Tests

    func test_init_withCustomModelName_usesCustomModel() {
        let customRecognizer: WhisperRecognizer = WhisperRecognizer(
            modelName: "openai_whisper-tiny.en",
            audioSession: mockAudioSession
        )

        // WhisperRecognizer가 생성되면 모델 이름이 저장됨
        // 직접 접근 불가하므로 생성 성공만 확인
        XCTAssertNotNil(customRecognizer)
    }

    func test_init_withDefaultAudioSession_createsAudioSessionManager() {
        let recognizer: WhisperRecognizer = WhisperRecognizer()
        XCTAssertNotNil(recognizer)
    }

    // MARK: - Restart Recognition Tests

    func test_startRecognition_whenAlreadyRecognizing_stopsFirst() async throws {
        guard sut.authorizationStatus == .authorized else {
            throw XCTSkip("Microphone permission required for this test")
        }

        do {
            try await sut.startRecognition()
            XCTAssertTrue(sut.isRecognizing)

            // 다시 시작하면 이전 인식을 중지하고 새로 시작
            try await sut.startRecognition()
            XCTAssertTrue(sut.isRecognizing)

            sut.stopRecognition()
        } catch SpeechRecognitionError.notAvailable {
            throw XCTSkip("WhisperKit model not available in test environment")
        }
    }

    // MARK: - SpeechRecognizing Protocol Conformance Tests

    func test_conformsToSpeechRecognizingProtocol() {
        let recognizer: any SpeechRecognizing = sut
        XCTAssertNotNil(recognizer)
    }

    func test_canBeUsedAsProtocolType() {
        func useRecognizer(_ recognizer: SpeechRecognizing) -> Bool {
            return recognizer.isRecognizing == false
        }

        XCTAssertTrue(useRecognizer(sut))
    }
}

// MARK: - Integration Tests (Requires Device)

/// WhisperKit 실제 동작 테스트
/// 이 테스트들은 실제 디바이스에서만 실행됨
@MainActor
final class WhisperRecognizerIntegrationTests: XCTestCase {

    var sut: WhisperRecognizer!

    override func setUp() async throws {
        try await super.setUp()

        #if targetEnvironment(simulator)
        throw XCTSkip("WhisperKit integration tests require a real device")
        #endif

        sut = WhisperRecognizer()

        // 권한 확인
        let status: SpeechAuthorizationStatus = await sut.requestAuthorization()
        guard status == .authorized else {
            throw XCTSkip("Microphone permission required for integration tests")
        }
    }

    override func tearDown() async throws {
        sut?.stopRecognition()
        sut = nil
        try await super.tearDown()
    }

    func test_fullRecognitionCycle_completesWithoutError() async throws {
        #if targetEnvironment(simulator)
        throw XCTSkip("WhisperKit integration tests require a real device")
        #endif

        // 인식 시작
        try await sut.startRecognition()
        XCTAssertTrue(sut.isRecognizing)

        // 짧은 대기 후 중지
        try await Task.sleep(nanoseconds: 500_000_000)

        // 인식 중지
        sut.stopRecognition()
        XCTAssertFalse(sut.isRecognizing)
    }
}
