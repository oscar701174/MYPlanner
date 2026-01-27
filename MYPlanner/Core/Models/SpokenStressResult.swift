//
//  SpokenStressResult.swift
//  MYPlanner
//
//  사용자가 발음한 음성의 강세 분석 결과
//  - 음절별 강세 정보
//  - Accent 표기 문자열
//

import Foundation

// MARK: - Spoken Stress Result

/// 강세 분석 결과
struct SpokenStressResult: Equatable, Sendable {
    /// 음절별 분석 결과
    let syllables: [SyllableStressInfo]

    /// Accent 표기 문자열 (예: "ihavaMEETing")
    let accentNotation: String

    /// 빈 결과
    static let empty: SpokenStressResult = SpokenStressResult(syllables: [], accentNotation: "")
}

// MARK: - Syllable Stress Info

/// 음절별 강세 정보
struct SyllableStressInfo: Equatable, Sendable {
    /// 음절 텍스트
    let text: String

    /// 시작 시간 (초)
    let startTime: TimeInterval

    /// 종료 시간 (초)
    let endTime: TimeInterval

    /// Duration (초)
    var duration: TimeInterval { endTime - startTime }

    /// 평균 Pitch (Hz)
    let pitch: Float

    /// 평균 Intensity (RMS)
    let intensity: Float

    /// 강세 레벨
    let stressLevel: StressLevel
}

// MARK: - Stress Level

/// 강세 레벨
enum StressLevel: Int, Equatable, Sendable, CaseIterable {
    case none = 0       // 무강세 → lowercase
    case primary = 1    // 주강세 → UPPERCASE
    case secondary = 2  // 부강세 → «markers»

    /// Accent 표기로 변환
    func format(_ text: String) -> String {
        switch self {
        case .primary:
            return text.uppercased()
        case .secondary:
            return "«\(text.lowercased())»"
        case .none:
            return text.lowercased()
        }
    }
}
