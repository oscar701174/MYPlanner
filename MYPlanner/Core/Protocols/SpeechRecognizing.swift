import Foundation

// MARK: - Speech Recognizing Protocol

/// 음성 인식 책임 (SRP: 오직 음성→텍스트 변환만)
@MainActor
protocol SpeechRecognizing: AnyObject {
    /// 현재 인식 상태
    var isRecognizing: Bool { get }

    /// 권한 상태
    var authorizationStatus: SpeechAuthorizationStatus { get }

    /// 인식 결과 스트림 (AsyncSequence)
    var recognitionResults: AsyncStream<SpeechRecognitionResult> { get }

    /// 녹음된 오디오 샘플 (강세 분석용)
    var recordedSamples: [Float] { get }

    /// 오디오 샘플 레이트
    var sampleRate: Int { get }

    /// 권한 요청
    func requestAuthorization() async -> SpeechAuthorizationStatus

    /// 인식 시작
    func startRecognition() async throws

    /// 인식 중지
    func stopRecognition()
}

// MARK: - Speech Recognition Error

/// 음성 인식 에러
enum SpeechRecognitionError: Error, Equatable, Sendable {
    case notAuthorized
    case notAvailable
    case audioEngineError
    case recognitionFailed(String)

    var localizedDescription: String {
        switch self {
        case .notAuthorized:
            return "Speech recognition is not authorized."
        case .notAvailable:
            return "Speech recognition is not available on this device."
        case .audioEngineError:
            return "Failed to start audio engine."
        case .recognitionFailed(let message):
            return "Recognition failed: \(message)"
        }
    }
}
