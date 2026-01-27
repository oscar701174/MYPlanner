//
//  SpokenStressAnalyzing.swift
//  MYPlanner
//
//  사용자가 발음한 음성에서 강세 패턴을 분석하는 Protocol
//  - 오디오 샘플에서 Pitch, Duration, Intensity 추출
//  - 음절별 강세 레벨 분류
//  - Accent 표기 생성
//

import Foundation

// MARK: - Spoken Stress Analyzing Protocol

/// 실제 발음된 음성에서 강세 패턴을 분석
protocol SpokenStressAnalyzing: Sendable {
    /// 오디오 샘플에서 강세 패턴 분석
    /// - Parameters:
    ///   - samples: PCM 오디오 샘플 (Float 배열)
    ///   - sampleRate: 샘플링 레이트 (예: 16000)
    ///   - recognizedText: 인식된 텍스트 (음절 매핑용)
    /// - Returns: 강세 분석 결과
    func analyzeStress(
        samples: [Float],
        sampleRate: Int,
        recognizedText: String
    ) -> SpokenStressResult
}
