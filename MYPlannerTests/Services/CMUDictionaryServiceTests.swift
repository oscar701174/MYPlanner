//
//  CMUDictionaryServiceTests.swift
//  MYPlannerTests
//
//  TDD Phase 1: CMU Dictionary parsing and lookup tests
//

import XCTest
@testable import MYPlanner

final class CMUDictionaryServiceTests: XCTestCase {

    var sut: CMUDictionaryService!

    override func setUp() {
        super.setUp()
        sut = CMUDictionaryService(testBundle: Bundle(for: type(of: self)))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Loading Tests

    func test_load_테스트데이터로드성공() {
        // When
        sut.load()

        // Then
        XCTAssertTrue(sut.isLoaded)
        XCTAssertGreaterThan(sut.wordCount, 0)
    }

    func test_load_주석라인무시() {
        // Given
        sut.load()

        // When
        let result: Pronunciation? = sut.lookup(";;;")

        // Then
        XCTAssertNil(result)
    }

    // MARK: - Lookup Tests

    func test_lookup_존재하는단어조회성공() {
        // Given
        sut.load()

        // When
        let result: Pronunciation? = sut.lookup("prepare")

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.word, "prepare")
    }

    func test_lookup_대소문자구분없이조회() {
        // Given
        sut.load()

        // When
        let lowercase: Pronunciation? = sut.lookup("prepare")
        let uppercase: Pronunciation? = sut.lookup("PREPARE")
        let mixed: Pronunciation? = sut.lookup("Prepare")

        // Then
        XCTAssertNotNil(lowercase)
        XCTAssertNotNil(uppercase)
        XCTAssertNotNil(mixed)
    }

    func test_lookup_존재하지않는단어nil반환() {
        // Given
        sut.load()

        // When
        let result: Pronunciation? = sut.lookup("xyzabc123")

        // Then
        XCTAssertNil(result)
    }

    func test_lookup_구두점포함단어정상조회() {
        // Given
        sut.load()

        // When
        let result: Pronunciation? = sut.lookup("prepare.")

        // Then
        XCTAssertNotNil(result)
    }

    // MARK: - Phoneme Parsing Tests

    func test_parsePhonemes_모음강세정보파싱() {
        // Given
        sut.load()

        // When
        let result: Pronunciation? = sut.lookup("prepare")

        // Then
        // PREPARE = P R IH0 P EH1 R
        // IH0 (무강세), EH1 (주강세)
        XCTAssertEqual(result?.syllableCount, 2)
        XCTAssertNotNil(result?.primaryStressIndex)
    }

    func test_parsePhonemes_자음은강세없음() {
        // Given
        sut.load()
        let result: Pronunciation? = sut.lookup("the")

        // When
        // THE = DH AH0
        let consonants: [Phoneme]? = result?.phonemes.filter { !$0.isVowel }

        // Then
        XCTAssertTrue(consonants?.allSatisfy { $0.stress == nil } ?? false)
    }

    func test_syllableCount_단음절() {
        // Given
        sut.load()

        // When
        let result: Pronunciation? = sut.lookup("the")

        // Then
        XCTAssertEqual(result?.syllableCount, 1)
    }

    func test_syllableCount_다음절() {
        // Given
        sut.load()

        // When
        let presentation: Pronunciation? = sut.lookup("presentation")

        // Then
        // PRESENTATION = P R EH2 Z AH0 N T EY1 SH AH0 N (4음절)
        XCTAssertEqual(presentation?.syllableCount, 4)
    }

    // MARK: - Primary Stress Tests

    func test_primaryStress_주강세위치확인() {
        // Given
        sut.load()

        // When
        let result: Pronunciation? = sut.lookup("meeting")

        // Then
        // MEETING = M IY1 T IH0 NG → IY1이 주강세
        XCTAssertNotNil(result?.primaryStressIndex)
    }

    func test_primaryStress_부강세포함단어() {
        // Given
        sut.load()

        // When
        let result: Pronunciation? = sut.lookup("important")

        // Then
        // IMPORTANT = IH2 M P AO1 R T AH0 N T
        // IH2 (부강세), AO1 (주강세)
        XCTAssertNotNil(result?.primaryStressIndex)
        XCTAssertTrue(result?.phonemes.contains { $0.stress == 2 } ?? false)
    }

    // MARK: - Contains Tests

    func test_contains_존재하는단어true() {
        // Given
        sut.load()

        // When
        let result: Bool = sut.contains("prepare")

        // Then
        XCTAssertTrue(result)
    }

    func test_contains_존재하지않는단어false() {
        // Given
        sut.load()

        // When
        let result: Bool = sut.contains("xyzabc123")

        // Then
        XCTAssertFalse(result)
    }
}
