//
//  SpokenStressAnalyzerTests.swift
//  MYPlannerTests
//
//  SpokenStressAnalyzer 단위 테스트
//  TDD: Red → Green → Refactor
//

import XCTest
@testable import MYPlanner

final class SpokenStressAnalyzerTests: XCTestCase {

    var sut: SpokenStressAnalyzer!

    override func setUp() {
        super.setUp()
        sut = SpokenStressAnalyzer.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - TDD Bug Fix Tests (Red Phase)
    // 이 테스트들은 현재 실패하는 버그를 재현합니다

    /// 버그 재현: 실제 음성과 유사한 데이터에서 강세가 감지되어야 함
    func test_analyzeStress_withRealisticAudio_shouldDetectStress() {
        // Given: 실제 음성과 유사한 오디오 데이터 생성
        // "I have a meeting" - meeting에 강세가 있어야 함
        let sampleRate: Int = 16000
        let samples: [Float] = generateSentenceSamples(
            sampleRate: sampleRate,
            wordStresses: [0.3, 0.4, 0.2, 1.0]  // meeting에 강세
        )
        let text: String = "I have a meeting"

        // When
        let result: SpokenStressResult = sut.analyzeStress(
            samples: samples,
            sampleRate: sampleRate,
            recognizedText: text
        )

        // Then: 강세가 감지되어야 함 (모두 소문자가 아니어야 함)
        XCTAssertFalse(result.accentNotation == text.lowercased().replacingOccurrences(of: " ", with: ""),
                       "Expected stress detection but got all lowercase: \(result.accentNotation)")
        XCTAssertTrue(result.accentNotation.contains(where: { $0.isUppercase }),
                      "Expected at least one uppercase character in: \(result.accentNotation)")
        // meeting이 대문자로 나와야 함
        XCTAssertTrue(result.accentNotation.uppercased().contains("MEETING"),
                      "Expected 'meeting' to be stressed in: \(result.accentNotation)")
    }

    /// 버그 재현: 강한 음절이 primary로 분류되어야 함
    func test_classifyStressLevel_withClearDifference_shouldHavePrimary() {
        // Given: 확실한 차이가 있는 음절들
        let syllables: [SyllableStressInfo] = [
            SyllableStressInfo(text: "meet", startTime: 0, endTime: 0.3, pitch: 250, intensity: 0.8, stressLevel: .none),
            SyllableStressInfo(text: "ing", startTime: 0.3, endTime: 0.5, pitch: 150, intensity: 0.3, stressLevel: .none)
        ]

        // When
        let result: [SyllableStressInfo] = sut.classifyStressLevel(syllables: syllables)

        // Then: 첫 번째 음절이 primary여야 함
        XCTAssertEqual(result[0].stressLevel, .primary,
                       "Expected 'meet' to be primary stress, got \(result[0].stressLevel)")
        XCTAssertNotEqual(result[1].stressLevel, .primary,
                          "Expected 'ing' to NOT be primary stress")
    }

    /// 버그 재현: 문장에서 최소 하나의 primary 강세가 있어야 함
    func test_analyzeStress_sentence_shouldHaveAtLeastOnePrimary() {
        // Given: 문장 오디오 시뮬레이션
        let sampleRate: Int = 16000
        // "I have a meeting" - meeting의 첫 음절에 강세
        let samples: [Float] = generateSentenceSamples(
            sampleRate: sampleRate,
            wordStresses: [0.3, 0.4, 0.2, 1.0]  // meeting에 강세
        )
        let text: String = "I have a meeting"

        // When
        let result: SpokenStressResult = sut.analyzeStress(
            samples: samples,
            sampleRate: sampleRate,
            recognizedText: text
        )

        // Then: 최소 하나의 primary 강세가 있어야 함
        let hasPrimary: Bool = result.syllables.contains { $0.stressLevel == .primary }
        XCTAssertTrue(hasPrimary,
                      "Expected at least one primary stress in sentence. Got: \(result.accentNotation)")
    }

    /// 버그 재현: 균일한 오디오에서도 최소한의 강세 구분이 있어야 함
    func test_analyzeStress_uniformAudio_shouldStillClassify() {
        // Given: 균일한 오디오 (현재 버그: 모두 none으로 분류됨)
        let sampleRate: Int = 16000
        let samples: [Float] = [Float](repeating: 0.5, count: sampleRate)  // 1초 균일 오디오
        let text: String = "hello"

        // When
        let result: SpokenStressResult = sut.analyzeStress(
            samples: samples,
            sampleRate: sampleRate,
            recognizedText: text
        )

        // Then: 균일한 오디오에서도 fallback으로 강세가 있어야 함
        // (첫 음절에 기본 강세 부여 등)
        XCTAssertFalse(result.accentNotation == "hello",
                       "Even with uniform audio, should have some stress marking")
    }

    // MARK: - Helper Methods for Test Data Generation

    /// 실제 음성과 유사한 샘플 생성 (강세 패턴 적용)
    private func generateRealisticSpeechSamples(sampleRate: Int, stressPattern: [Float]) -> [Float] {
        var samples: [Float] = []
        let syllableDuration: Float = 0.3  // 300ms per syllable

        for (index, stress) in stressPattern.enumerated() {
            let syllableSamples: Int = Int(Float(sampleRate) * syllableDuration)
            let baseFrequency: Float = 150 + stress * 100  // 강세에 따라 주파수 변화
            let amplitude: Float = 0.3 + stress * 0.5  // 강세에 따라 진폭 변화

            for i in 0..<syllableSamples {
                let t: Float = Float(i) / Float(sampleRate)
                // 음성은 여러 주파수의 합성
                let sample: Float = amplitude * (
                    0.6 * sin(2 * Float.pi * baseFrequency * t) +
                    0.3 * sin(2 * Float.pi * baseFrequency * 2 * t) +
                    0.1 * sin(2 * Float.pi * baseFrequency * 3 * t)
                )
                samples.append(sample)
            }

            // 음절 사이 짧은 무음
            if index < stressPattern.count - 1 {
                let silenceSamples: Int = Int(Float(sampleRate) * 0.05)
                samples.append(contentsOf: [Float](repeating: 0, count: silenceSamples))
            }
        }

        return samples
    }

    /// 문장 오디오 샘플 생성
    private func generateSentenceSamples(sampleRate: Int, wordStresses: [Float]) -> [Float] {
        var samples: [Float] = []

        for (index, stress) in wordStresses.enumerated() {
            let wordDuration: Float = 0.2 + stress * 0.2  // 강세 있는 단어가 더 김
            let wordSamples: Int = Int(Float(sampleRate) * wordDuration)
            let frequency: Float = 120 + stress * 80
            let amplitude: Float = 0.2 + stress * 0.6

            for i in 0..<wordSamples {
                let t: Float = Float(i) / Float(sampleRate)
                let sample: Float = amplitude * sin(2 * Float.pi * frequency * t)
                samples.append(sample)
            }

            // 단어 사이 무음
            if index < wordStresses.count - 1 {
                let silenceSamples: Int = Int(Float(sampleRate) * 0.1)
                samples.append(contentsOf: [Float](repeating: 0, count: silenceSamples))
            }
        }

        return samples
    }

    // MARK: - Data Model Tests

    func test_stressLevel_format_primary() {
        // Given
        let level: StressLevel = .primary

        // When
        let result: String = level.format("meet")

        // Then
        XCTAssertEqual(result, "MEET")
    }

    func test_stressLevel_format_secondary() {
        // Given
        let level: StressLevel = .secondary

        // When
        let result: String = level.format("pre")

        // Then
        XCTAssertEqual(result, "«pre»")
    }

    func test_stressLevel_format_none() {
        // Given
        let level: StressLevel = .none

        // When
        let result: String = level.format("THE")

        // Then
        XCTAssertEqual(result, "the")
    }

    func test_spokenStressResult_empty() {
        // Given & When
        let result: SpokenStressResult = .empty

        // Then
        XCTAssertTrue(result.syllables.isEmpty)
        XCTAssertEqual(result.accentNotation, "")
    }

    func test_syllableStressInfo_duration() {
        // Given
        let info: SyllableStressInfo = SyllableStressInfo(
            text: "meet",
            startTime: 0.5,
            endTime: 0.8,
            pitch: 200,
            intensity: 0.5,
            stressLevel: .primary
        )

        // When
        let duration: TimeInterval = info.duration

        // Then
        XCTAssertEqual(duration, 0.3, accuracy: 0.001)
    }

    // MARK: - Syllabification Tests

    func test_syllabifyText_singleWord() {
        // Given
        let text: String = "meeting"

        // When
        let syllables: [String] = sut.syllabifyText(text)

        // Then
        XCTAssertFalse(syllables.isEmpty)
        XCTAssertEqual(syllables.joined(), "meeting")
    }

    func test_syllabifyText_multipleWords() {
        // Given
        let text: String = "I have a meeting"

        // When
        let syllables: [String] = sut.syllabifyText(text)

        // Then
        XCTAssertFalse(syllables.isEmpty)
        XCTAssertTrue(syllables.count >= 4)  // 최소 4개 단어
    }

    func test_syllabifyText_emptyString() {
        // Given
        let text: String = ""

        // When
        let syllables: [String] = sut.syllabifyText(text)

        // Then
        XCTAssertTrue(syllables.isEmpty)
    }

    func test_syllabifyText_withPunctuation() {
        // Given
        let text: String = "Hello, world!"

        // When
        let syllables: [String] = sut.syllabifyText(text)

        // Then
        XCTAssertFalse(syllables.isEmpty)
        // 구두점이 제거되어야 함
        XCTAssertFalse(syllables.joined().contains(","))
        XCTAssertFalse(syllables.joined().contains("!"))
    }

    // MARK: - RMS Calculation Tests

    func test_calculateRMS_silence() {
        // Given
        let samples: [Float] = [Float](repeating: 0, count: 100)

        // When
        let rms: Float = sut.calculateRMS(samples: samples)

        // Then
        XCTAssertEqual(rms, 0, accuracy: 0.001)
    }

    func test_calculateRMS_constantValue() {
        // Given
        let samples: [Float] = [Float](repeating: 0.5, count: 100)

        // When
        let rms: Float = sut.calculateRMS(samples: samples)

        // Then
        XCTAssertEqual(rms, 0.5, accuracy: 0.001)
    }

    func test_calculateRMS_sineWave() {
        // Given: 단위 진폭의 사인파 (RMS = 1/sqrt(2) ≈ 0.707)
        let samples: [Float] = (0..<1000).map { Float(sin(Double($0) * 0.1)) }

        // When
        let rms: Float = sut.calculateRMS(samples: samples)

        // Then
        XCTAssertEqual(rms, 0.707, accuracy: 0.05)
    }

    func test_calculateRMS_emptySamples() {
        // Given
        let samples: [Float] = []

        // When
        let rms: Float = sut.calculateRMS(samples: samples)

        // Then
        XCTAssertEqual(rms, 0)
    }

    // MARK: - Pitch Extraction Tests

    func test_extractPitch_silence() {
        // Given
        let samples: [Float] = [Float](repeating: 0, count: 1000)
        let sampleRate: Int = 16000

        // When
        let pitch: Float = sut.extractPitch(samples: samples, sampleRate: sampleRate)

        // Then
        XCTAssertEqual(pitch, 0)
    }

    func test_extractPitch_knownFrequency() {
        // Given: 200Hz 사인파 생성
        let sampleRate: Int = 16000
        let frequency: Float = 200
        let duration: Float = 0.5
        let sampleCount: Int = Int(Float(sampleRate) * duration)

        let samples: [Float] = (0..<sampleCount).map { i in
            sin(2 * Float.pi * frequency * Float(i) / Float(sampleRate))
        }

        // When
        let detectedPitch: Float = sut.extractPitch(samples: samples, sampleRate: sampleRate)

        // Then
        // Autocorrelation은 정확하지 않을 수 있으므로 넓은 허용 범위
        XCTAssertEqual(detectedPitch, frequency, accuracy: 30)
    }

    func test_extractPitch_shortSamples() {
        // Given
        let samples: [Float] = [0.1, 0.2, 0.3]
        let sampleRate: Int = 16000

        // When
        let pitch: Float = sut.extractPitch(samples: samples, sampleRate: sampleRate)

        // Then
        XCTAssertEqual(pitch, 0)
    }

    // MARK: - Boundary Detection Tests

    func test_detectSyllableBoundaries_silence() {
        // Given
        let samples: [Float] = [Float](repeating: 0, count: 8000)
        let sampleRate: Int = 16000

        // When
        let boundaries: [Int] = sut.detectSyllableBoundaries(samples: samples, sampleRate: sampleRate)

        // Then
        XCTAssertEqual(boundaries.first, 0)
        XCTAssertEqual(boundaries.last, samples.count)
    }

    func test_detectSyllableBoundaries_singleBurst() {
        // Given: 무음 + 소리 + 무음
        var samples: [Float] = [Float](repeating: 0, count: 4000)
        samples.append(contentsOf: [Float](repeating: 0.5, count: 4000))
        samples.append(contentsOf: [Float](repeating: 0, count: 4000))
        let sampleRate: Int = 16000

        // When
        let boundaries: [Int] = sut.detectSyllableBoundaries(samples: samples, sampleRate: sampleRate)

        // Then
        XCTAssertGreaterThanOrEqual(boundaries.count, 2)
        XCTAssertEqual(boundaries.first, 0)
        XCTAssertEqual(boundaries.last, samples.count)
    }

    func test_detectSyllableBoundaries_shortSamples() {
        // Given
        let samples: [Float] = [0.1, 0.2, 0.3]
        let sampleRate: Int = 16000

        // When
        let boundaries: [Int] = sut.detectSyllableBoundaries(samples: samples, sampleRate: sampleRate)

        // Then
        XCTAssertEqual(boundaries, [0, samples.count])
    }

    // MARK: - Stress Classification Tests

    func test_classifyStressLevel_emptySyllables() {
        // Given
        let syllables: [SyllableStressInfo] = []

        // When
        let result: [SyllableStressInfo] = sut.classifyStressLevel(syllables: syllables)

        // Then
        XCTAssertTrue(result.isEmpty)
    }

    func test_classifyStressLevel_singleSyllable() {
        // Given
        let syllables: [SyllableStressInfo] = [
            SyllableStressInfo(
                text: "test",
                startTime: 0,
                endTime: 0.5,
                pitch: 200,
                intensity: 0.5,
                stressLevel: .none
            )
        ]

        // When
        let result: [SyllableStressInfo] = sut.classifyStressLevel(syllables: syllables)

        // Then
        XCTAssertEqual(result.count, 1)
        // 단일 음절은 정규화 후 0.5가 되어 secondary 또는 primary
        XCTAssertNotEqual(result[0].stressLevel, .none)
    }

    func test_classifyStressLevel_multipleSyllables_differentIntensity() {
        // Given: 두 번째 음절이 더 강한 경우
        let syllables: [SyllableStressInfo] = [
            SyllableStressInfo(text: "pre", startTime: 0, endTime: 0.2, pitch: 150, intensity: 0.3, stressLevel: .none),
            SyllableStressInfo(text: "pare", startTime: 0.2, endTime: 0.5, pitch: 200, intensity: 0.8, stressLevel: .none)
        ]

        // When
        let result: [SyllableStressInfo] = sut.classifyStressLevel(syllables: syllables)

        // Then
        XCTAssertEqual(result.count, 2)
        // 두 번째 음절이 더 강해야 함
        XCTAssertTrue(result[1].stressLevel.rawValue >= result[0].stressLevel.rawValue)
    }

    // MARK: - Notation Generation Tests

    func test_generateAccentNotation_empty() {
        // Given
        let syllables: [SyllableStressInfo] = []

        // When
        let result: String = sut.generateAccentNotation(syllables: syllables)

        // Then
        XCTAssertEqual(result, "")
    }

    func test_generateAccentNotation_mixed() {
        // Given
        let syllables: [SyllableStressInfo] = [
            SyllableStressInfo(text: "pre", startTime: 0, endTime: 0.2, pitch: 150, intensity: 0.3, stressLevel: .none),
            SyllableStressInfo(text: "PARE", startTime: 0.2, endTime: 0.5, pitch: 200, intensity: 0.8, stressLevel: .primary)
        ]

        // When
        let result: String = sut.generateAccentNotation(syllables: syllables)

        // Then
        XCTAssertEqual(result, "prePARE")
    }

    func test_generateAccentNotation_allStressLevels() {
        // Given
        let syllables: [SyllableStressInfo] = [
            SyllableStressInfo(text: "un", startTime: 0, endTime: 0.1, pitch: 100, intensity: 0.2, stressLevel: .secondary),
            SyllableStressInfo(text: "der", startTime: 0.1, endTime: 0.2, pitch: 150, intensity: 0.5, stressLevel: .none),
            SyllableStressInfo(text: "stand", startTime: 0.2, endTime: 0.4, pitch: 200, intensity: 0.8, stressLevel: .primary)
        ]

        // When
        let result: String = sut.generateAccentNotation(syllables: syllables)

        // Then
        XCTAssertEqual(result, "«un»derSTAND")
    }

    // MARK: - Integration Tests

    func test_analyzeStress_emptyInput() {
        // Given
        let samples: [Float] = []
        let sampleRate: Int = 16000
        let text: String = ""

        // When
        let result: SpokenStressResult = sut.analyzeStress(
            samples: samples,
            sampleRate: sampleRate,
            recognizedText: text
        )

        // Then
        XCTAssertEqual(result, .empty)
    }

    func test_analyzeStress_emptySamples() {
        // Given
        let samples: [Float] = []
        let sampleRate: Int = 16000
        let text: String = "hello"

        // When
        let result: SpokenStressResult = sut.analyzeStress(
            samples: samples,
            sampleRate: sampleRate,
            recognizedText: text
        )

        // Then
        XCTAssertEqual(result, .empty)
    }

    func test_analyzeStress_emptyText() {
        // Given
        let samples: [Float] = [Float](repeating: 0.5, count: 8000)
        let sampleRate: Int = 16000
        let text: String = ""

        // When
        let result: SpokenStressResult = sut.analyzeStress(
            samples: samples,
            sampleRate: sampleRate,
            recognizedText: text
        )

        // Then
        XCTAssertEqual(result, .empty)
    }

    func test_analyzeStress_validInput() {
        // Given: 간단한 오디오 시뮬레이션
        let sampleRate: Int = 16000
        let duration: Float = 1.0
        let sampleCount: Int = Int(Float(sampleRate) * duration)

        // 변화하는 진폭의 사인파
        let samples: [Float] = (0..<sampleCount).map { i in
            let amplitude: Float = 0.3 + 0.5 * sin(Float(i) / Float(sampleRate) * 2 * Float.pi)
            return amplitude * sin(2 * Float.pi * 200 * Float(i) / Float(sampleRate))
        }

        let text: String = "hello"

        // When
        let result: SpokenStressResult = sut.analyzeStress(
            samples: samples,
            sampleRate: sampleRate,
            recognizedText: text
        )

        // Then
        XCTAssertFalse(result.syllables.isEmpty)
        XCTAssertFalse(result.accentNotation.isEmpty)
    }

    func test_analyzeStress_multipleWords() {
        // Given
        let sampleRate: Int = 16000
        let samples: [Float] = [Float](repeating: 0.5, count: 16000)
        let text: String = "I have a meeting"

        // When
        let result: SpokenStressResult = sut.analyzeStress(
            samples: samples,
            sampleRate: sampleRate,
            recognizedText: text
        )

        // Then
        XCTAssertFalse(result.accentNotation.isEmpty)
        // 원본 텍스트의 글자들이 포함되어야 함 (대소문자 무관)
        let lowerNotation: String = result.accentNotation.lowercased().replacingOccurrences(of: "«", with: "").replacingOccurrences(of: "»", with: "")
        XCTAssertTrue(lowerNotation.contains("i"))
        XCTAssertTrue(lowerNotation.contains("have"))
    }
}
