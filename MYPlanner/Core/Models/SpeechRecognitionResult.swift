import Foundation

// MARK: - Speech Authorization Status

/// 음성 인식 권한 상태
enum SpeechAuthorizationStatus: Equatable, Sendable {
    case notDetermined
    case denied
    case restricted
    case authorized
}

// MARK: - Speech Recognition Result

/// 음성 인식 결과
struct SpeechRecognitionResult: Equatable, Sendable {
    /// 인식된 전체 텍스트
    let text: String

    /// 최종 결과 여부 (실시간 업데이트 vs 확정)
    let isFinal: Bool

    /// 단어별 세그먼트 정보
    let segments: [SpeechSegment]

    /// 전체 인식 신뢰도 (0.0 ~ 1.0)
    let confidence: Float
}

// MARK: - Speech Segment

/// 음성 인식 세그먼트 (단어 단위)
struct SpeechSegment: Equatable, Sendable {
    /// 인식된 텍스트
    let text: String

    /// 신뢰도 (0.0 ~ 1.0)
    let confidence: Float

    /// 시작 시간 (초)
    let timestamp: TimeInterval

    /// 발화 길이 (초)
    let duration: TimeInterval
}
