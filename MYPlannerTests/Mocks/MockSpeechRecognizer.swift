import Foundation
@testable import MYPlanner

// MARK: - Mock Speech Recognizer

/// 테스트용 Mock 음성 인식기
@MainActor
final class MockSpeechRecognizer: SpeechRecognizing {

    // MARK: - Stub Values

    var stubAuthorizationStatus: SpeechAuthorizationStatus = .authorized
    var stubError: SpeechRecognitionError?

    // MARK: - Call Tracking

    var requestAuthorizationCallCount: Int = 0
    var startRecognitionCallCount: Int = 0
    var stopRecognitionCallCount: Int = 0

    // MARK: - State

    private(set) var isRecognizing: Bool = false
    var recordedSamples: [Float] = []
    var sampleRate: Int = 16000

    var authorizationStatus: SpeechAuthorizationStatus {
        return stubAuthorizationStatus
    }

    // MARK: - AsyncStream

    private var continuation: AsyncStream<SpeechRecognitionResult>.Continuation?

    var recognitionResults: AsyncStream<SpeechRecognitionResult> {
        return AsyncStream { continuation in
            self.continuation = continuation
        }
    }

    // MARK: - Protocol Methods

    func requestAuthorization() async -> SpeechAuthorizationStatus {
        requestAuthorizationCallCount += 1
        return stubAuthorizationStatus
    }

    func startRecognition() async throws {
        startRecognitionCallCount += 1

        if let error = stubError {
            throw error
        }

        isRecognizing = true
    }

    func stopRecognition() {
        stopRecognitionCallCount += 1
        isRecognizing = false
        continuation?.finish()
    }

    // MARK: - Test Helpers

    /// 테스트에서 결과 시뮬레이션
    func simulateResult(_ result: SpeechRecognitionResult) {
        continuation?.yield(result)
    }

    /// 테스트에서 최종 결과 시뮬레이션 후 종료
    func simulateFinalResult(_ result: SpeechRecognitionResult) {
        continuation?.yield(result)
        continuation?.finish()
        isRecognizing = false
    }

    /// 상태 초기화
    func reset() {
        requestAuthorizationCallCount = 0
        startRecognitionCallCount = 0
        stopRecognitionCallCount = 0
        isRecognizing = false
        stubError = nil
        stubAuthorizationStatus = .authorized
    }
}
