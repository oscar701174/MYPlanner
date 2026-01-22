import Foundation

// MARK: - Pronunciation Score

/// 발음 평가 점수
struct PronunciationScore: Equatable, Sendable {
    /// 전체 정확도 (0.0 ~ 1.0)
    let overallAccuracy: Float

    /// 단어별 결과
    let wordResults: [WordResult]

    /// 평가 등급
    var grade: PronunciationGrade {
        switch overallAccuracy {
        case 0.9...1.0:
            return .excellent
        case 0.7..<0.9:
            return .good
        case 0.5..<0.7:
            return .fair
        default:
            return .needsPractice
        }
    }
}

// MARK: - Pronunciation Grade

/// 발음 평가 등급
enum PronunciationGrade: Equatable, Sendable {
    case excellent      // 90% 이상
    case good           // 70-89%
    case fair           // 50-69%
    case needsPractice  // 50% 미만

    var emoji: String {
        switch self {
        case .excellent:
            return "🌟"
        case .good:
            return "👍"
        case .fair:
            return "💪"
        case .needsPractice:
            return "📚"
        }
    }

    var message: String {
        switch self {
        case .excellent:
            return "Excellent!"
        case .good:
            return "Good job!"
        case .fair:
            return "Keep practicing!"
        case .needsPractice:
            return "Try again!"
        }
    }
}

// MARK: - Word Result

/// 단어별 발음 결과
struct WordResult: Equatable, Sendable {
    /// 원본 단어
    let originalWord: String

    /// 인식된 단어 (nil = 누락)
    let recognizedWord: String?

    /// 신뢰도 (0.0 ~ 1.0)
    let confidence: Float

    /// 발음 상태
    let status: WordStatus
}

// MARK: - Word Status

/// 단어 발음 상태
enum WordStatus: Equatable, Sendable {
    case correct        // 정확히 발음
    case mispronounced  // 다르게 발음
    case missing        // 누락
    case extra          // 추가로 발음
}
