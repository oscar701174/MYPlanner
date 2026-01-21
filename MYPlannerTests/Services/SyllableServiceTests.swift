//
//  SyllableServiceTests.swift
//  MYPlannerTests
//
//  TDD Phase 2: Syllable separation and spelling mapping tests
//

import XCTest
@testable import MYPlanner

final class SyllableServiceTests: XCTestCase {

    var sut: SyllableService!
    var cmuService: CMUDictionaryService!

    override func setUp() {
        super.setUp()
        sut = SyllableService.shared
        cmuService = CMUDictionaryService(testBundle: Bundle(for: type(of: self)))
        cmuService.load()
    }

    override func tearDown() {
        sut = nil
        cmuService = nil
        super.tearDown()
    }

    // MARK: - Syllable Count Tests

    func test_syllabify_단음절단어() {
        // Given
        let pronunciation: Pronunciation = cmuService.lookup("the")!

        // When
        let syllables: [Syllable] = sut.syllabify(phonemes: pronunciation.phonemes, word: "the")

        // Then
        XCTAssertEqual(syllables.count, 1)
        XCTAssertEqual(syllables[0].spelling, "the")
    }

    func test_syllabify_2음절단어() {
        // Given
        let pronunciation: Pronunciation = cmuService.lookup("prepare")!

        // When
        let syllables: [Syllable] = sut.syllabify(phonemes: pronunciation.phonemes, word: "prepare")

        // Then
        XCTAssertEqual(syllables.count, 2)
    }

    func test_syllabify_3음절단어() {
        // Given
        let pronunciation: Pronunciation = cmuService.lookup("important")!

        // When
        let syllables: [Syllable] = sut.syllabify(phonemes: pronunciation.phonemes, word: "important")

        // Then
        XCTAssertEqual(syllables.count, 3)
    }

    func test_syllabify_4음절단어() {
        // Given
        let pronunciation: Pronunciation = cmuService.lookup("presentation")!

        // When
        let syllables: [Syllable] = sut.syllabify(phonemes: pronunciation.phonemes, word: "presentation")

        // Then
        XCTAssertEqual(syllables.count, 4)
    }

    // MARK: - Stress Assignment Tests

    func test_syllabify_주강세음절표시() {
        // Given
        let pronunciation: Pronunciation = cmuService.lookup("prepare")!

        // When
        let syllables: [Syllable] = sut.syllabify(phonemes: pronunciation.phonemes, word: "prepare")

        // Then
        let primaryStressSyllable: Syllable? = syllables.first { $0.isPrimaryStress }
        XCTAssertNotNil(primaryStressSyllable)
    }

    func test_syllabify_부강세음절표시() {
        // Given
        let pronunciation: Pronunciation = cmuService.lookup("important")!

        // When
        let syllables: [Syllable] = sut.syllabify(phonemes: pronunciation.phonemes, word: "important")

        // Then
        let secondaryStressSyllable: Syllable? = syllables.first { $0.isSecondaryStress }
        XCTAssertNotNil(secondaryStressSyllable)
    }

    // MARK: - Spelling Mapping Tests

    func test_syllabify_철자매핑_prepare() {
        // Given
        let pronunciation: Pronunciation = cmuService.lookup("prepare")!

        // When
        let syllables: [Syllable] = sut.syllabify(phonemes: pronunciation.phonemes, word: "prepare")

        // Then
        let combined: String = syllables.map { $0.spelling }.joined()
        XCTAssertEqual(combined, "prepare")
    }

    func test_syllabify_철자매핑_meeting() {
        // Given
        let pronunciation: Pronunciation = cmuService.lookup("meeting")!

        // When
        let syllables: [Syllable] = sut.syllabify(phonemes: pronunciation.phonemes, word: "meeting")

        // Then
        let combined: String = syllables.map { $0.spelling }.joined()
        XCTAssertEqual(combined, "meeting")
    }

    func test_syllabify_철자매핑_presentation() {
        // Given
        let pronunciation: Pronunciation = cmuService.lookup("presentation")!

        // When
        let syllables: [Syllable] = sut.syllabify(phonemes: pronunciation.phonemes, word: "presentation")

        // Then
        let combined: String = syllables.map { $0.spelling }.joined()
        XCTAssertEqual(combined, "presentation")
    }

    // MARK: - Edge Cases

    func test_syllabify_빈음소배열() {
        // Given
        let emptyPhonemes: [Phoneme] = []

        // When
        let syllables: [Syllable] = sut.syllabify(phonemes: emptyPhonemes, word: "test")

        // Then
        XCTAssertEqual(syllables.count, 1)
        XCTAssertEqual(syllables[0].spelling, "test")
    }
}
