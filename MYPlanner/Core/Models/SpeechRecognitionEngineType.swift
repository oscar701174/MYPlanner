import Foundation

// MARK: - Speech Recognition Engine Type

/// 음성 인식 엔진 타입
enum SpeechRecognitionEngineType: String, CaseIterable, Identifiable, Sendable {
    case apple = "apple"       // iOS Speech Framework (온라인/오프라인)
    case whisper = "whisper"   // WhisperKit (완전 오프라인)

    var id: String { rawValue }

    /// 표시 이름
    var displayName: String {
        switch self {
        case .apple:
            return "Apple Speech"
        case .whisper:
            return "Whisper (On-device)"
        }
    }

    /// 설명
    var description: String {
        switch self {
        case .apple:
            return "iOS 기본 음성 인식 (빠름, 네트워크 사용 가능)"
        case .whisper:
            return "WhisperKit 로컬 인식 (정확함, 완전 오프라인)"
        }
    }

    /// 아이콘 이름 (SF Symbols)
    var iconName: String {
        switch self {
        case .apple:
            return "apple.logo"
        case .whisper:
            return "waveform.badge.mic"
        }
    }
}
