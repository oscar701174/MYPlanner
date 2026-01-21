//
//  AccentFormatterTests.swift
//  MYPlannerTests
//
//  TDD Phase 3: Accent formatting and output tests
//

import XCTest
@testable import MYPlanner

final class AccentFormatterTests: XCTestCase {

    var sut: AccentFormatter!

    override func setUp() {
        super.setUp()
        let testBundle: Bundle = Bundle(for: type(of: self))
        sut = AccentFormatter(testBundle: testBundle)
    }

    override func tearDown() {
        sut.clearCache()
        sut = nil
        super.tearDown()
    }

    // MARK: - Single Word Tests

    func test_formatWord_주강세대문자표시() {
        // Given
        let word: String = "prepare"

        // When
        let result: String = sut.formatWord(word)

        // Then
        // "prepare" → "pre-PARE"
        XCTAssertTrue(result.contains(where: { $0.isUppercase }))
    }

    func test_formatWord_하이픈으로음절구분() {
        // Given
        let word: String = "meeting"

        // When
        let result: String = sut.formatWord(word)

        // Then
        XCTAssertTrue(result.contains("-"))
    }

    func test_formatWord_단음절하이픈없음() {
        // Given
        let word: String = "the"

        // When
        let result: String = sut.formatWord(word)

        // Then
        XCTAssertFalse(result.contains("-"))
    }

    func test_formatWord_사전에없는단어원본반환() {
        // Given
        let word: String = "xyzabc123"

        // When
        let result: String = sut.formatWord(word)

        // Then
        XCTAssertEqual(result, word)
    }

    // MARK: - Sentence Tests

    func test_format_문장전체변환() {
        // Given
        let sentence: String = "Prepare for the meeting"

        // When
        let result: String = sut.format(sentence)

        // Then
        XCTAssertTrue(result.contains("PARE") || result.contains("MEET"))
    }

    func test_format_공백유지() {
        // Given
        let sentence: String = "the meeting"

        // When
        let result: String = sut.format(sentence)
        let wordCount: Int = result.components(separatedBy: " ").count

        // Then
        XCTAssertEqual(wordCount, 2)
    }

    // MARK: - Punctuation Tests

    func test_formatWord_마침표유지() {
        // Given
        let word: String = "meeting."

        // When
        let result: String = sut.formatWord(word)

        // Then
        XCTAssertTrue(result.hasSuffix("."))
    }

    func test_formatWord_쉼표유지() {
        // Given
        let word: String = "meeting,"

        // When
        let result: String = sut.formatWord(word)

        // Then
        XCTAssertTrue(result.hasSuffix(","))
    }

    func test_formatWord_물음표유지() {
        // Given
        let word: String = "meeting?"

        // When
        let result: String = sut.formatWord(word)

        // Then
        XCTAssertTrue(result.hasSuffix("?"))
    }

    func test_formatWord_앞쪽구두점유지() {
        // Given
        let word: String = "\"meeting"

        // When
        let result: String = sut.formatWord(word)

        // Then
        XCTAssertTrue(result.hasPrefix("\""))
    }

    // MARK: - Case Preservation Tests

    func test_formatWord_첫글자대문자유지() {
        // Given
        let word: String = "Prepare"

        // When
        let result: String = sut.formatWord(word)

        // Then
        XCTAssertTrue(result.first?.isUppercase ?? false)
    }

    // MARK: - Cache Tests

    func test_cache_동일단어캐시사용() {
        // Given
        let word: String = "prepare"

        // When
        let first: String = sut.formatWord(word)
        let second: String = sut.formatWord(word)

        // Then
        XCTAssertEqual(first, second)
    }

    func test_clearCache_캐시클리어() {
        // Given
        _ = sut.formatWord("prepare")

        // When
        sut.clearCache()

        // Then (캐시 클리어 후에도 동일한 결과)
        let result: String = sut.formatWord("prepare")
        XCTAssertTrue(result.contains("-"))
    }

    // MARK: - Secondary Stress Tests

    func test_formatWord_부강세마커표시_important() {
        // Given - IMPORTANT has secondary stress on first syllable (IH2)
        let word: String = "important"

        // When
        let result: String = sut.formatWord(word)

        // Then
        // Should contain secondary stress markers «»
        let prefix: String = AccentFormatter.secondaryStressPrefix
        let suffix: String = AccentFormatter.secondaryStressSuffix
        XCTAssertTrue(result.contains(prefix), "Should contain secondary stress prefix «, got: \(result)")
        XCTAssertTrue(result.contains(suffix), "Should contain secondary stress suffix », got: \(result)")
    }

    func test_formatWord_부강세마커표시_presentation() {
        // Given - PRESENTATION has secondary stress on first syllable (EH2)
        let word: String = "presentation"

        // When
        let result: String = sut.formatWord(word)

        // Then
        let prefix: String = AccentFormatter.secondaryStressPrefix
        let suffix: String = AccentFormatter.secondaryStressSuffix
        XCTAssertTrue(result.contains(prefix), "Should contain secondary stress prefix «, got: \(result)")
        XCTAssertTrue(result.contains(suffix), "Should contain secondary stress suffix », got: \(result)")
    }

    func test_formatWord_3가지강세레벨_important() {
        // Given - IMPORTANT: IH2 M P AO1 R T AH0 N T
        // Expected: «im»-POR-tant (secondary-primary-none)
        let word: String = "important"

        // When
        let result: String = sut.formatWord(word)

        // Then
        // Check for all three stress levels
        let hasSecondary: Bool = result.contains("«") && result.contains("»")
        let hasUppercase: Bool = result.contains(where: { $0.isUppercase })
        let hasLowercase: Bool = result.contains(where: { $0.isLowercase && $0.isLetter })

        XCTAssertTrue(hasSecondary, "Should have secondary stress markers, got: \(result)")
        XCTAssertTrue(hasUppercase, "Should have uppercase for primary stress, got: \(result)")
        XCTAssertTrue(hasLowercase, "Should have lowercase for no stress, got: \(result)")

        print("IMPORTANT formatted: \(result)")
    }

    // MARK: - Integration Tests

    func test_format_실제문장테스트() {
        // Given
        let sentence: String = "I have a product review today."

        // When
        let result: String = sut.format(sentence)

        // Then
        // 최소한 일부 단어가 악센트 표시됨
        XCTAssertTrue(result.contains(where: { $0.isUppercase }))
        XCTAssertTrue(result.hasSuffix("."))
    }

    func test_format_MYPlanner예제문장() {
        // Given
        let sentences: [String] = [
            "Prepare for the meeting",
            "Review the product schedule",
            "Practice English expression"
        ]

        // When & Then
        for sentence: String in sentences {
            let result: String = sut.format(sentence)
            // 각 문장이 변환되고, 악센트 표시가 있어야 함
            XCTAssertFalse(result.isEmpty)
            XCTAssertTrue(result.contains(where: { $0.isUppercase }))
        }
    }
}
