//
//  PracticeRecord.swift
//  MYPlanner
//
//  발음 연습 기록 모델 - SwiftData @Model
//  - 연습 결과 저장
//  - 단어별 발음 결과 저장
//  - Expression과 연결
//

import Foundation
import SwiftData

@Model
final class PracticeRecord {
    var id: UUID
    var expression: Expression?

    // MARK: - Score Data

    /// 전체 정확도 (0.0 ~ 1.0)
    var overallAccuracy: Float

    /// 인식된 텍스트
    var recognizedText: String

    /// 원본 텍스트
    var originalText: String

    /// 사용한 엔진 타입 (apple / whisper)
    var engineType: String

    // MARK: - Word Results (JSON encoded)

    /// 단어별 결과 (JSON)
    var wordResultsData: Data?

    // MARK: - Timestamp

    var practicedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        expression: Expression? = nil,
        overallAccuracy: Float,
        recognizedText: String,
        originalText: String,
        engineType: String = "apple",
        wordResults: [WordResult] = [],
        practicedAt: Date = Date()
    ) {
        self.id = id
        self.expression = expression
        self.overallAccuracy = overallAccuracy
        self.recognizedText = recognizedText
        self.originalText = originalText
        self.engineType = engineType
        self.practicedAt = practicedAt

        // Encode word results to JSON
        self.wordResultsData = Self.encodeWordResults(wordResults)
    }

    // MARK: - Word Results Encoding/Decoding

    /// WordResult 배열을 JSON Data로 인코딩
    private static func encodeWordResults(_ results: [WordResult]) -> Data? {
        let codableResults: [CodableWordResult] = results.map { CodableWordResult(from: $0) }
        return try? JSONEncoder().encode(codableResults)
    }

    /// JSON Data를 WordResult 배열로 디코딩
    var wordResults: [WordResult] {
        guard let data = wordResultsData else { return [] }
        guard let codableResults: [CodableWordResult] = try? JSONDecoder().decode([CodableWordResult].self, from: data) else {
            return []
        }
        return codableResults.map { $0.toWordResult() }
    }

    // MARK: - Computed Properties

    /// 발음 평가 등급
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

    /// PronunciationScore 객체로 변환
    var pronunciationScore: PronunciationScore {
        PronunciationScore(
            overallAccuracy: overallAccuracy,
            wordResults: wordResults
        )
    }

    /// 정확히 발음한 단어 수
    var correctWordCount: Int {
        wordResults.filter { $0.status == .correct }.count
    }

    /// 전체 단어 수
    var totalWordCount: Int {
        wordResults.filter { $0.status != .extra }.count
    }

    /// 틀린 단어 목록
    var incorrectWords: [WordResult] {
        wordResults.filter { $0.status == .mispronounced || $0.status == .missing }
    }
}

// MARK: - Codable Word Result (for JSON serialization)

/// SwiftData에 저장 가능한 WordResult 형태
private struct CodableWordResult: Codable {
    let originalWord: String
    let recognizedWord: String?
    let confidence: Float
    let status: String

    init(from wordResult: WordResult) {
        self.originalWord = wordResult.originalWord
        self.recognizedWord = wordResult.recognizedWord
        self.confidence = wordResult.confidence
        self.status = wordResult.status.rawValue
    }

    func toWordResult() -> WordResult {
        WordResult(
            originalWord: originalWord,
            recognizedWord: recognizedWord,
            confidence: confidence,
            status: WordStatus(rawValue: status) ?? .missing
        )
    }
}

// MARK: - WordStatus Raw Value Support

extension WordStatus: RawRepresentable {
    typealias RawValue = String

    init?(rawValue: String) {
        switch rawValue {
        case "correct": self = .correct
        case "mispronounced": self = .mispronounced
        case "missing": self = .missing
        case "extra": self = .extra
        default: return nil
        }
    }

    var rawValue: String {
        switch self {
        case .correct: return "correct"
        case .mispronounced: return "mispronounced"
        case .missing: return "missing"
        case .extra: return "extra"
        }
    }
}
