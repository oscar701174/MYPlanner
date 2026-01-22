//
//  TTSServiceTests.swift
//  MYPlannerTests
//
//  Step 10: TDD for TTSService
//

import XCTest
@testable import MYPlanner

final class TTSServiceTests: XCTestCase {

    var sut: TTSService!

    override func setUp() {
        super.setUp()
        sut = TTSService()
    }

    override func tearDown() {
        sut.stop()
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_isSpeakingIsFalse() {
        // Assert
        XCTAssertFalse(sut.isSpeaking)
    }

    func test_init_defaultRateIsSet() {
        // Assert
        XCTAssertEqual(sut.rate, 0.5, accuracy: 0.01)
    }

    func test_init_defaultPitchIsOne() {
        // Assert
        XCTAssertEqual(sut.pitch, 1.0, accuracy: 0.01)
    }

    func test_init_defaultVolumeIsOne() {
        // Assert
        XCTAssertEqual(sut.volume, 1.0, accuracy: 0.01)
    }

    func test_init_defaultLanguageIsEnglish() {
        // Assert
        XCTAssertEqual(sut.language, "en-US")
    }

    func test_init_currentWordIsEmpty() {
        // Assert
        XCTAssertEqual(sut.currentWord, "")
    }

    // MARK: - Speak Tests

    func test_speak_withEmptyText_doesNotSpeak() {
        // Arrange
        let emptyText = ""

        // Act
        sut.speak(emptyText)

        // Assert
        XCTAssertFalse(sut.isSpeaking)
    }

    func test_speak_withWhitespaceOnly_doesNotSpeak() {
        // Arrange
        let whitespaceText = "   \n\t  "

        // Act
        sut.speak(whitespaceText)

        // Assert
        XCTAssertFalse(sut.isSpeaking)
    }

    func test_speak_withValidText_triggersSynthesizer() async {
        // Arrange
        let text = "Hello"

        // Act
        sut.speak(text)

        // Wait for delegate to be called
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Assert
        XCTAssertTrue(sut.isSpeaking)
    }

    // MARK: - Stop Tests

    func test_stop_setsIsSpeakingToFalse() {
        // Arrange
        sut.speak("Test")

        // Act
        sut.stop()

        // Assert
        XCTAssertFalse(sut.isSpeaking)
    }

    func test_stop_clearsCurrentWord() {
        // Arrange
        sut.speak("Test")

        // Act
        sut.stop()

        // Assert
        XCTAssertEqual(sut.currentWord, "")
    }

    // MARK: - Configuration Tests

    func test_rate_canBeChanged() {
        // Arrange
        let newRate: Float = 0.3

        // Act
        sut.rate = newRate

        // Assert
        XCTAssertEqual(sut.rate, newRate)
    }

    func test_pitch_canBeChanged() {
        // Arrange
        let newPitch: Float = 1.5

        // Act
        sut.pitch = newPitch

        // Assert
        XCTAssertEqual(sut.pitch, newPitch)
    }

    func test_volume_canBeChanged() {
        // Arrange
        let newVolume: Float = 0.7

        // Act
        sut.volume = newVolume

        // Assert
        XCTAssertEqual(sut.volume, newVolume)
    }

    func test_language_canBeChanged() {
        // Arrange
        let newLanguage = "en-GB"

        // Act
        sut.language = newLanguage

        // Assert
        XCTAssertEqual(sut.language, newLanguage)
    }

    // MARK: - Multiple Speak Tests

    func test_speak_calledTwice_stopsFirstAndStartsSecond() async {
        // Arrange
        let firstText = "First sentence"
        let secondText = "Second sentence"

        // Act
        sut.speak(firstText)

        // Wait for first speech to start
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Speak second text (should stop first)
        sut.speak(secondText)

        // Wait for second speech to start
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Assert - should still be speaking (the second text)
        XCTAssertTrue(sut.isSpeaking)
    }
}
