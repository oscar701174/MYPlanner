//
//  SpokenStressAnalyzer.swift
//  MYPlanner
//
//  사용자가 발음한 음성에서 강세 패턴을 분석하는 서비스
//  - 단어별 Pitch 분석 (시간축 pitch contour)
//  - Pitch + Intensity 결합 점수로 강세 분류
//  - Accent 표기 생성
//
//  개선된 접근법:
//  1. 프레임별 pitch contour 추출
//  2. 단어를 시간축에 균등 배치
//  3. 각 단어 구간의 평균 pitch와 intensity 계산
//  4. Pitch 60% + Intensity 40% 가중치로 강세 점수 산출
//

import Foundation
import Accelerate

// MARK: - Spoken Stress Analyzer

final class SpokenStressAnalyzer: SpokenStressAnalyzing, @unchecked Sendable {

    // MARK: - Constants

    private let frameSize: Int = 512
    private let hopSize: Int = 256
    private let minPitchFreq: Float = 75   // 사람 목소리 최저 주파수
    private let maxPitchFreq: Float = 500  // 사람 목소리 최고 주파수

    // 강세 분류 가중치 (Pitch를 더 중요하게)
    private let pitchWeight: Float = 0.60
    private let intensityWeight: Float = 0.40

    // MARK: - Singleton

    static let shared: SpokenStressAnalyzer = SpokenStressAnalyzer()

    private init() {}

    // MARK: - SpokenStressAnalyzing

    func analyzeStress(
        samples: [Float],
        sampleRate: Int,
        recognizedText: String
    ) -> SpokenStressResult {
        guard !samples.isEmpty, !recognizedText.isEmpty else {
            return .empty
        }

        // 단어 기반 접근법: 단어별로 pitch와 intensity 분석
        let words: [String] = recognizedText.lowercased()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }

        guard !words.isEmpty else {
            return SpokenStressResult(syllables: [], accentNotation: recognizedText.lowercased())
        }

        // 1. 전체 pitch contour 추출
        let pitchContour: [(time: Double, pitch: Float)] = extractPitchContour(
            samples: samples,
            sampleRate: sampleRate
        )

        // 2. 단어별 특성 추출 (균등 시간 분할)
        let totalDuration: Double = Double(samples.count) / Double(sampleRate)
        let wordDuration: Double = totalDuration / Double(words.count)
        let samplesPerWord: Int = samples.count / words.count

        var syllableInfos: [SyllableStressInfo] = []

        for (index, word) in words.enumerated() {
            let startTime: Double = Double(index) * wordDuration
            let endTime: Double = startTime + wordDuration
            let startSample: Int = index * samplesPerWord
            let endSample: Int = min((index + 1) * samplesPerWord, samples.count)

            // 해당 시간 범위의 pitch 값들
            let pitchesInRange: [Float] = pitchContour
                .filter { $0.time >= startTime && $0.time < endTime }
                .map { $0.pitch }
                .filter { $0 > 0 }

            let avgPitch: Float = pitchesInRange.isEmpty ? 0 : pitchesInRange.reduce(0, +) / Float(pitchesInRange.count)

            // 해당 단어 구간의 intensity
            let wordSamples: [Float] = Array(samples[startSample..<endSample])
            let intensity: Float = calculateRMS(samples: wordSamples)

            let info: SyllableStressInfo = SyllableStressInfo(
                text: word,
                startTime: startTime,
                endTime: endTime,
                pitch: avgPitch,
                intensity: intensity,
                stressLevel: .none
            )
            syllableInfos.append(info)
        }

        // 3. 강세 레벨 분류 (Pitch + Intensity 결합)
        let classifiedSyllables: [SyllableStressInfo] = classifyByPitchAndIntensity(syllables: syllableInfos)

        // 4. Accent 표기 생성
        let notation: String = generateAccentNotation(syllables: classifiedSyllables)

        return SpokenStressResult(
            syllables: classifiedSyllables,
            accentNotation: notation
        )
    }

    // MARK: - Pitch Contour Extraction

    /// 시간에 따른 pitch 변화 추출 (프레임별)
    private func extractPitchContour(samples: [Float], sampleRate: Int) -> [(time: Double, pitch: Float)] {
        var contour: [(time: Double, pitch: Float)] = []

        var i: Int = 0
        while i + frameSize < samples.count {
            let frame: [Float] = Array(samples[i..<(i + frameSize)])
            let time: Double = Double(i) / Double(sampleRate)
            let pitch: Float = extractPitchFromFrame(frame: frame, sampleRate: sampleRate)

            contour.append((time: time, pitch: pitch))
            i += hopSize
        }

        return contour
    }

    /// 단일 프레임에서 pitch 추출 (정규화된 Autocorrelation)
    private func extractPitchFromFrame(frame: [Float], sampleRate: Int) -> Float {
        let minLag: Int = sampleRate / Int(maxPitchFreq)
        let maxLag: Int = min(sampleRate / Int(minPitchFreq), frame.count - 1)

        guard minLag < maxLag && maxLag < frame.count else { return 0 }

        // 에너지가 너무 낮으면 무음으로 처리
        let energy: Float = frame.reduce(0) { $0 + $1 * $1 } / Float(frame.count)
        guard energy > 0.0005 else { return 0 }

        var bestLag: Int = 0
        var bestCorrelation: Float = -Float.infinity

        // Normalized Autocorrelation
        for lag in minLag..<maxLag {
            var correlation: Float = 0
            var norm1: Float = 0
            var norm2: Float = 0

            for i in 0..<(frame.count - lag) {
                correlation += frame[i] * frame[i + lag]
                norm1 += frame[i] * frame[i]
                norm2 += frame[i + lag] * frame[i + lag]
            }

            let normalizer: Float = sqrt(norm1 * norm2)
            if normalizer > 0.0001 {
                correlation /= normalizer
            }

            if correlation > bestCorrelation {
                bestCorrelation = correlation
                bestLag = lag
            }
        }

        // Correlation이 낮으면 pitch가 불확실
        guard bestCorrelation > 0.25 && bestLag > 0 else { return 0 }

        return Float(sampleRate) / Float(bestLag)
    }

    // MARK: - Stress Classification (Pitch + Intensity)

    /// Pitch와 Intensity를 결합하여 강세 분류
    private func classifyByPitchAndIntensity(syllables: [SyllableStressInfo]) -> [SyllableStressInfo] {
        guard !syllables.isEmpty else { return [] }

        // 1. Combined score 계산
        let scores: [Float] = calculateCombinedScores(syllables: syllables)

        // 2. Percentile 기반 분류
        let sortedScores: [Float] = scores.sorted(by: >)
        guard !sortedScores.isEmpty else {
            return applyFallbackStress(syllables: syllables)
        }

        // 상위 25%: primary, 25-60%: secondary, 나머지: none
        let primaryIndex: Int = max(0, Int(Float(sortedScores.count) * 0.25) - 1)
        let secondaryIndex: Int = max(primaryIndex, Int(Float(sortedScores.count) * 0.60) - 1)

        let primaryThreshold: Float = sortedScores[primaryIndex]
        let secondaryThreshold: Float = sortedScores[secondaryIndex]

        // 3. 분류 적용
        var classified: [SyllableStressInfo] = []
        var hasPrimary: Bool = false
        var maxScoreIndex: Int = 0
        var maxScore: Float = -1

        for (index, syllable) in syllables.enumerated() {
            let score: Float = scores[index]

            if score > maxScore {
                maxScore = score
                maxScoreIndex = index
            }

            let level: StressLevel
            if score >= primaryThreshold && score > 0 {
                level = .primary
                hasPrimary = true
            } else if score >= secondaryThreshold && score > 0 {
                level = .secondary
            } else {
                level = .none
            }

            classified.append(SyllableStressInfo(
                text: syllable.text,
                startTime: syllable.startTime,
                endTime: syllable.endTime,
                pitch: syllable.pitch,
                intensity: syllable.intensity,
                stressLevel: level
            ))
        }

        // 4. 최소 1개 primary 보장
        if !hasPrimary && !classified.isEmpty {
            let syllable: SyllableStressInfo = classified[maxScoreIndex]
            classified[maxScoreIndex] = SyllableStressInfo(
                text: syllable.text,
                startTime: syllable.startTime,
                endTime: syllable.endTime,
                pitch: syllable.pitch,
                intensity: syllable.intensity,
                stressLevel: .primary
            )
        }

        return classified
    }

    /// Combined score 계산 (Pitch 60% + Intensity 40%)
    private func calculateCombinedScores(syllables: [SyllableStressInfo]) -> [Float] {
        let pitches: [Float] = syllables.map { $0.pitch }
        let intensities: [Float] = syllables.map { $0.intensity }

        let validPitches: [Float] = pitches.filter { $0 > 0 }
        let maxPitch: Float = validPitches.max() ?? 1
        let minPitch: Float = validPitches.min() ?? 0
        let maxIntensity: Float = intensities.max() ?? 1
        let minIntensity: Float = intensities.min() ?? 0

        return syllables.map { syllable in
            let normPitch: Float
            if maxPitch > minPitch && syllable.pitch > 0 {
                normPitch = (syllable.pitch - minPitch) / (maxPitch - minPitch)
            } else {
                normPitch = 0.5
            }

            let normIntensity: Float
            if maxIntensity > minIntensity {
                normIntensity = (syllable.intensity - minIntensity) / (maxIntensity - minIntensity)
            } else {
                normIntensity = 0.5
            }

            return normPitch * pitchWeight + normIntensity * intensityWeight
        }
    }

    /// Fallback: 첫 단어에 기본 강세 부여
    private func applyFallbackStress(syllables: [SyllableStressInfo]) -> [SyllableStressInfo] {
        guard !syllables.isEmpty else { return [] }

        return syllables.enumerated().map { (index, syllable) in
            SyllableStressInfo(
                text: syllable.text,
                startTime: syllable.startTime,
                endTime: syllable.endTime,
                pitch: syllable.pitch,
                intensity: syllable.intensity,
                stressLevel: index == 0 ? .primary : .none
            )
        }
    }

    // MARK: - Legacy Syllable Methods (for backward compatibility)

    /// 텍스트를 음절로 분리 (레거시 - 단어 단위로 변경됨)
    func syllabifyText(_ text: String) -> [String] {
        // 단어별로 분리 (음절 대신 단어 사용)
        let words: [String] = text.lowercased()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }

        var allSyllables: [String] = []

        for word in words {
            let cleanWord: String = word.trimmingCharacters(in: .punctuationCharacters)
            let syllables: [String] = syllabifyWord(cleanWord)
            allSyllables.append(contentsOf: syllables)
        }

        return allSyllables
    }

    /// 단어를 음절로 분리 (간단한 규칙 기반)
    private func syllabifyWord(_ word: String) -> [String] {
        guard !word.isEmpty else { return [] }

        // 짧은 단어는 그대로 반환
        if word.count <= 2 {
            return [word]
        }

        let vowels: Set<Character> = ["a", "e", "i", "o", "u", "y"]
        var syllables: [String] = []
        var currentSyllable: String = ""
        var lastWasVowel: Bool = false

        for (index, char) in word.enumerated() {
            let isVowel: Bool = vowels.contains(char)
            currentSyllable.append(char)

            // 모음 다음에 자음이 오고, 그 뒤에 모음이 있으면 분리
            if lastWasVowel && !isVowel {
                let remaining: String = String(word.dropFirst(index + 1))
                let hasNextVowel: Bool = remaining.contains { vowels.contains($0) }

                if hasNextVowel && currentSyllable.count > 1 {
                    // 마지막 자음을 다음 음절로 이동
                    let syllable: String = String(currentSyllable.dropLast())
                    if !syllable.isEmpty {
                        syllables.append(syllable)
                        currentSyllable = String(char)
                    }
                }
            }

            lastWasVowel = isVowel
        }

        // 남은 부분 추가
        if !currentSyllable.isEmpty {
            syllables.append(currentSyllable)
        }

        return syllables.isEmpty ? [word] : syllables
    }

    // MARK: - Boundary Detection

    /// 에너지 기반 음절 경계 감지
    func detectSyllableBoundaries(samples: [Float], sampleRate: Int) -> [Int] {
        guard samples.count > frameSize else {
            return [0, samples.count]
        }

        var boundaries: [Int] = [0]
        var energies: [Float] = []

        // 프레임별 에너지 계산
        var i: Int = 0
        while i + frameSize < samples.count {
            let frame: [Float] = Array(samples[i..<(i + frameSize)])
            let energy: Float = calculateRMS(samples: frame)
            energies.append(energy)
            i += hopSize
        }

        guard !energies.isEmpty else {
            return [0, samples.count]
        }

        // 에너지 스무딩 (간단한 이동 평균)
        let smoothedEnergies: [Float] = smoothEnergies(energies, windowSize: 3)

        // 동적 임계값 계산
        let maxEnergy: Float = smoothedEnergies.max() ?? 1
        let threshold: Float = 0.25 * maxEnergy

        // Rising edge 감지
        var wasAboveThreshold: Bool = false
        var lastBoundary: Int = 0
        let minSyllableLength: Int = sampleRate / 10  // 최소 100ms

        for (index, energy) in smoothedEnergies.enumerated() {
            let isAboveThreshold: Bool = energy > threshold
            let currentSample: Int = index * hopSize

            if isAboveThreshold && !wasAboveThreshold {
                // 최소 음절 길이 확인
                if currentSample - lastBoundary > minSyllableLength {
                    boundaries.append(currentSample)
                    lastBoundary = currentSample
                }
            }

            wasAboveThreshold = isAboveThreshold
        }

        boundaries.append(samples.count)
        return boundaries
    }

    /// 에너지 스무딩
    private func smoothEnergies(_ energies: [Float], windowSize: Int) -> [Float] {
        guard energies.count >= windowSize else { return energies }

        var smoothed: [Float] = []
        let halfWindow: Int = windowSize / 2

        for i in 0..<energies.count {
            let start: Int = max(0, i - halfWindow)
            let end: Int = min(energies.count, i + halfWindow + 1)
            let window: ArraySlice<Float> = energies[start..<end]
            let avg: Float = window.reduce(0, +) / Float(window.count)
            smoothed.append(avg)
        }

        return smoothed
    }

    // MARK: - Feature Extraction

    /// RMS 에너지 계산 (Intensity)
    func calculateRMS(samples: [Float]) -> Float {
        guard !samples.isEmpty else { return 0 }

        var sumOfSquares: Float = 0
        vDSP_svesq(samples, 1, &sumOfSquares, vDSP_Length(samples.count))

        return sqrt(sumOfSquares / Float(samples.count))
    }

    /// Autocorrelation 기반 Pitch 추출
    func extractPitch(samples: [Float], sampleRate: Int) -> Float {
        guard samples.count > 100 else { return 0 }

        let minLag: Int = sampleRate / Int(maxPitchFreq)
        let maxLag: Int = min(sampleRate / Int(minPitchFreq), samples.count - 1)

        guard minLag < maxLag else { return 0 }

        var bestLag: Int = 0
        var bestCorrelation: Float = 0

        // Autocorrelation 계산
        for lag in minLag..<maxLag {
            var correlation: Float = 0
            let length: Int = samples.count - lag

            // vDSP를 사용한 최적화된 계산
            vDSP_dotpr(samples, 1, Array(samples[lag..<samples.count]), 1, &correlation, vDSP_Length(length))

            // 정규화
            correlation /= Float(length)

            if correlation > bestCorrelation {
                bestCorrelation = correlation
                bestLag = lag
            }
        }

        guard bestLag > 0 else { return 0 }
        return Float(sampleRate) / Float(bestLag)
    }

    // MARK: - Legacy Public Methods (for backward compatibility with tests)

    /// 강세 레벨 분류 (레거시 - classifyByPitchAndIntensity로 대체됨)
    func classifyStressLevel(syllables: [SyllableStressInfo]) -> [SyllableStressInfo] {
        return classifyByPitchAndIntensity(syllables: syllables)
    }

    // MARK: - Notation Generation

    /// 강세 분석 결과를 Accent 표기로 변환
    func generateAccentNotation(syllables: [SyllableStressInfo]) -> String {
        guard !syllables.isEmpty else { return "" }

        return syllables.map { syllable in
            syllable.stressLevel.format(syllable.text)
        }.joined()
    }
}
