//
//  ProsodyFormatterTests.swift
//  MYPlannerTests
//
//  TDD: Prosody formatting tests
//  Tests for thought groups, linking, function word reduction, schwa notation
//

import XCTest
@testable import MYPlanner

final class ProsodyFormatterTests: XCTestCase {

    var sut: ProsodyFormatter!

    override func setUp() {
        super.setUp()
        let testBundle: Bundle = Bundle(for: type(of: self))
        sut = ProsodyFormatter(testBundle: testBundle)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Basic Formatting Tests

    func test_format_기본문장_완전연결() {
        // Given
        let sentence: String = "I am a boy"

        // When
        let result: String = sut.format(sentence)

        // Then
        XCTAssertFalse(result.isEmpty)
        // Should NOT contain spaces (except thought group separators)
        XCTAssertFalse(result.contains(" "), "Should not contain spaces between words, got: \(result)")
        // Should be completely connected: "Iamaboy" or similar
        print("Basic (connected): \(result)")
    }

    func test_format_단어연결_공백하이픈없음() {
        // Given
        let sentence: String = "I want to go"

        // When
        let result: String = sut.format(sentence)

        // Then
        // Words should be completely connected with NO spaces between words
        // Hyphens only appear WITHIN multi-syllable words (e.g., "MEET-ing")
        XCTAssertFalse(result.contains(" "), "Should not contain spaces, got: \(result)")
        print("Connected (no word separators): \(result)")
    }

    // MARK: - Linking Tests

    func test_format_연음_자음모음연결() {
        // Given
        let sentence: String = "an apple"
        let options = ProsodyOptions(
            showLinking: true,
            showThoughtGroups: false,
            showReducedPronunciation: false,
            showFunctionWordMarkers: false
        )

        // When
        let result: String = sut.format(sentence, options: options)

        // Then
        // "an" ends with 'n' (consonant), "apple" starts with 'a' (vowel)
        // Should link: an‿apple
        XCTAssertTrue(result.contains("‿"), "Should contain linking marker, got: \(result)")
        print("Linking: \(result)")
    }

    func test_format_연음_자음자음_직접연결() {
        // Given
        let sentence: String = "want milk"
        let options = ProsodyOptions(
            showLinking: true,
            showThoughtGroups: false,
            showReducedPronunciation: false,
            showFunctionWordMarkers: false
        )

        // When
        let result: String = sut.format(sentence, options: options)

        // Then
        // "want" ends with 't' (consonant), "milk" starts with 'm' (consonant)
        // Should NOT use linking marker, just connect directly
        XCTAssertFalse(result.contains("‿"), "Should not contain linking marker for consonant-consonant, got: \(result)")
        XCTAssertFalse(result.contains(" "), "Should not contain spaces, got: \(result)")
        print("Consonant-consonant direct connection: \(result)")
    }

    // MARK: - Thought Group Tests

    func test_format_의미단위_쉼표에서끊기() {
        // Given
        let sentence: String = "I went to the store, and bought milk"
        let options = ProsodyOptions(
            showLinking: false,
            showThoughtGroups: true,
            showReducedPronunciation: false,
            showFunctionWordMarkers: false
        )

        // When
        let result: String = sut.format(sentence, options: options)

        // Then
        // Thought group separator " / " is the ONLY place with spaces
        XCTAssertTrue(result.contains(" / "), "Should contain thought group separator with spaces, got: \(result)")
        print("Thought Group: \(result)")
    }

    func test_format_의미단위_접속사앞에서끊기() {
        // Given
        let sentence: String = "I study hard because I want to succeed"
        let options = ProsodyOptions(
            showLinking: false,
            showThoughtGroups: true,
            showReducedPronunciation: false,
            showFunctionWordMarkers: false
        )

        // When
        let result: String = sut.format(sentence, options: options)

        // Then
        // "because" should trigger thought group
        XCTAssertTrue(result.contains(" / "), "Should contain thought group before conjunction, got: \(result)")
        print("Conjunction break: \(result)")
    }

    func test_format_의미단위만_공백있음() {
        // Given
        let sentence: String = "I went to the store, and bought milk"
        let options = ProsodyOptions(
            showLinking: false,
            showThoughtGroups: true,
            showReducedPronunciation: false,
            showFunctionWordMarkers: false
        )

        // When
        let result: String = sut.format(sentence, options: options)

        // Then
        // Split by " / " and check each part has no internal spaces
        let parts = result.components(separatedBy: " / ")
        for part in parts {
            XCTAssertFalse(part.contains(" "), "Each thought group should have no internal spaces, got: \(part)")
        }
        // Each part should be completely connected (no hyphens between words)
        print("Parts (connected speech): \(parts)")
    }

    // MARK: - Reduced Pronunciation Tests

    func test_format_약화발음_to() {
        // Given
        let sentence: String = "I want to go"
        let options = ProsodyOptions(
            showLinking: false,
            showThoughtGroups: false,
            showReducedPronunciation: true,
            showFunctionWordMarkers: false
        )

        // When
        let result: String = sut.format(sentence, options: options)

        // Then
        XCTAssertTrue(result.contains("tə"), "Should contain reduced 'to' → 'tə', got: \(result)")
        print("Reduced to: \(result)")
    }

    func test_format_약화발음_the() {
        // Given
        let sentence: String = "go to the store"
        let options = ProsodyOptions(
            showLinking: false,
            showThoughtGroups: false,
            showReducedPronunciation: true,
            showFunctionWordMarkers: false
        )

        // When
        let result: String = sut.format(sentence, options: options)

        // Then
        XCTAssertTrue(result.contains("thə"), "Should contain reduced 'the' → 'thə', got: \(result)")
        print("Reduced the: \(result)")
    }

    func test_format_약화발음_and() {
        // Given
        let sentence: String = "bread and butter"
        let options = ProsodyOptions(
            showLinking: false,
            showThoughtGroups: false,
            showReducedPronunciation: true,
            showFunctionWordMarkers: false
        )

        // When
        let result: String = sut.format(sentence, options: options)

        // Then
        XCTAssertTrue(result.contains("ən"), "Should contain reduced 'and' → 'ən', got: \(result)")
        print("Reduced and: \(result)")
    }

    // MARK: - Function Word Marker Tests

    func test_format_기능어마커_표시() {
        // Given
        let sentence: String = "I want to go"
        let options = ProsodyOptions(
            showLinking: false,
            showThoughtGroups: false,
            showReducedPronunciation: true,
            showFunctionWordMarkers: true
        )

        // When
        let result: String = sut.format(sentence, options: options)

        // Then
        XCTAssertTrue(result.contains("‹"), "Should contain function word prefix, got: \(result)")
        XCTAssertTrue(result.contains("›"), "Should contain function word suffix, got: \(result)")
        print("Function word markers: \(result)")
    }

    // MARK: - Full Format Tests

    func test_formatWithProsody_전체기능() {
        // Given
        let sentence: String = "I want to go to the store, and buy an apple."

        // When
        let result: String = sut.formatWithProsody(sentence)

        // Then
        XCTAssertFalse(result.isEmpty)
        print("Full prosody: \(result)")
    }

    func test_formatWithFullNotation_모든마커표시() {
        // Given
        let sentence: String = "I want to go to the store."

        // When
        let result: String = sut.formatWithFullNotation(sentence)

        // Then
        XCTAssertFalse(result.isEmpty)
        // Should have function word markers
        XCTAssertTrue(result.contains("‹") || result.contains("tə"), "Should show reduced forms or markers, got: \(result)")
        print("Full notation: \(result)")
    }

    // MARK: - Integration with Accent Tests

    func test_format_강세와연음통합() {
        // Given
        let sentence: String = "Prepare for the meeting"
        let options = ProsodyOptions(
            showLinking: true,
            showThoughtGroups: false,
            showReducedPronunciation: true,
            showFunctionWordMarkers: false
        )

        // When
        let result: String = sut.format(sentence, options: options)

        // Then
        // Should have uppercase for stress
        XCTAssertTrue(result.contains(where: { $0.isUppercase }), "Should contain uppercase stress, got: \(result)")
        print("Stress + Prosody: \(result)")
    }

    // MARK: - 30 Example Sentences Test Suite

    /// 30개 예시 문장 테스트 - 완전 연결 검증
    func test_30Examples_완전연결_공백없음() {
        // 30개 예시 문장
        let sentences: [String] = [
            // 1-5: 기본 문장
            "I am a boy",
            "She is my friend",
            "We are students",
            "They have a car",
            "It is a beautiful day",

            // 6-10: 일상 대화
            "How are you doing today",
            "What time is it now",
            "Where do you live",
            "Can I help you",
            "Nice to meet you",

            // 11-15: 직장/학교 상황
            "I have a meeting at nine",
            "Please send me the report",
            "Let me check my schedule",
            "I need to finish this project",
            "Can we reschedule the appointment",

            // 16-20: 쇼핑/식당
            "How much does it cost",
            "I would like to order coffee",
            "Do you have this in blue",
            "Can I pay by card",
            "The food was delicious",

            // 21-25: 여행/교통
            "Where is the nearest station",
            "I need a taxi to the airport",
            "What time does the train leave",
            "Is this seat taken",
            "How long does it take",

            // 26-30: 복잡한 문장
            "I want to go to the store and buy some groceries",
            "She told me that she would call me back later",
            "If you have any questions please let me know",
            "I have been working here for five years",
            "Could you please repeat that more slowly"
        ]

        print("\n" + String(repeating: "=", count: 60))
        print("30 Example Sentences - Connected Speech Test")
        print(String(repeating: "=", count: 60))

        for (index, sentence) in sentences.enumerated() {
            let result: String = sut.format(sentence)

            // 각 문장에 공백이 없어야 함 (thought group 제외)
            let hasUnexpectedSpace: Bool = result
                .replacingOccurrences(of: " / ", with: "")
                .contains(" ")

            XCTAssertFalse(hasUnexpectedSpace,
                "[\(index + 1)] Should not contain spaces: '\(sentence)' → '\(result)'")

            print("[\(String(format: "%02d", index + 1))] \(sentence)")
            print("     → \(result)")
            print("")
        }

        print(String(repeating: "=", count: 60))
    }

    /// 30개 예시 문장 - 연음(Linking) 테스트
    func test_30Examples_연음테스트() {
        let sentences: [String] = [
            // 자음+모음 연음 케이스
            "an apple",
            "an orange",
            "an egg",
            "at eight",
            "is it",
            "not at all",
            "pick it up",
            "turn it on",
            "check it out",
            "think about it"
        ]

        let options = ProsodyOptions(
            showLinking: true,
            showThoughtGroups: false,
            showReducedPronunciation: false,
            showFunctionWordMarkers: false
        )

        print("\n" + String(repeating: "=", count: 60))
        print("Linking (연음) Test - Consonant + Vowel")
        print(String(repeating: "=", count: 60))

        for (index, sentence) in sentences.enumerated() {
            let result: String = sut.format(sentence, options: options)

            // 연음 마커(‿)가 있어야 함
            XCTAssertTrue(result.contains("‿"),
                "[\(index + 1)] Should contain linking marker: '\(sentence)' → '\(result)'")

            print("[\(String(format: "%02d", index + 1))] \(sentence) → \(result)")
        }

        print(String(repeating: "=", count: 60))
    }

    /// 30개 예시 문장 - 약화 발음 테스트
    func test_30Examples_약화발음테스트() {
        let sentences: [(String, String)] = [
            // (문장, 예상되는 약화 형태)
            ("I want to go", "tə"),
            ("go to the store", "tə"),
            ("go to the store", "thə"),
            ("bread and butter", "ən"),
            ("give it to me", "tə"),
            ("I have to work", "tə"),
            ("for the people", "thə"),
            ("in the morning", "thə"),
            ("you and me", "ən"),
            ("this and that", "ən")
        ]

        let options = ProsodyOptions(
            showLinking: false,
            showThoughtGroups: false,
            showReducedPronunciation: true,
            showFunctionWordMarkers: false
        )

        print("\n" + String(repeating: "=", count: 60))
        print("Reduced Pronunciation (약화 발음) Test")
        print(String(repeating: "=", count: 60))

        for (index, (sentence, expectedReduction)) in sentences.enumerated() {
            let result: String = sut.format(sentence, options: options)

            XCTAssertTrue(result.contains(expectedReduction),
                "[\(index + 1)] Should contain '\(expectedReduction)': '\(sentence)' → '\(result)'")

            print("[\(String(format: "%02d", index + 1))] \(sentence) → \(result) (expects: \(expectedReduction))")
        }

        print(String(repeating: "=", count: 60))
    }

    /// 30개 예시 문장 - Thought Group 테스트
    func test_30Examples_의미단위테스트() {
        let sentences: [String] = [
            // 쉼표가 있는 문장
            "Hello, how are you",
            "Yes, I understand",
            "Well, let me think",
            "Actually, I disagree",
            "First, we need to plan",

            // 접속사가 있는 문장
            "I study hard because I want to succeed",
            "She left early because she was tired",
            "I will go if you come with me",
            "He works hard but he is happy",
            "I like coffee and she likes tea"
        ]

        let options = ProsodyOptions(
            showLinking: false,
            showThoughtGroups: true,
            showReducedPronunciation: false,
            showFunctionWordMarkers: false
        )

        print("\n" + String(repeating: "=", count: 60))
        print("Thought Groups (의미 단위) Test")
        print(String(repeating: "=", count: 60))

        for (index, sentence) in sentences.enumerated() {
            let result: String = sut.format(sentence, options: options)

            // Thought group separator가 있어야 함
            XCTAssertTrue(result.contains(" / "),
                "[\(index + 1)] Should contain thought group separator: '\(sentence)' → '\(result)'")

            // 각 thought group 내부에는 공백이 없어야 함
            let parts: [String] = result.components(separatedBy: " / ")
            for part in parts {
                XCTAssertFalse(part.contains(" "),
                    "[\(index + 1)] Thought group should not contain spaces: '\(part)'")
            }

            print("[\(String(format: "%02d", index + 1))] \(sentence)")
            print("     → \(result)")
        }

        print(String(repeating: "=", count: 60))
    }

    /// 전체 기능 통합 테스트 - 30개 문장
    func test_30Examples_전체통합테스트() {
        let sentences: [String] = [
            "I am a boy",
            "She is my friend",
            "We are going to the park",
            "I want to buy an apple",
            "Can you help me with this",
            "I have a meeting at three",
            "Please send me the file",
            "What time does it start",
            "I would like to order food",
            "How much does this cost",
            "Where is the nearest bank",
            "I need to catch a train",
            "The weather is nice today",
            "I have been waiting for you",
            "Could you repeat that please",
            "I will call you back later",
            "She told me about the plan",
            "If you need help let me know",
            "I work from nine to five",
            "Thank you for your help",
            "Nice to meet you too",
            "I am looking for a job",
            "Can I have the check please",
            "What do you recommend",
            "I will think about it",
            "Let me know when you arrive",
            "I appreciate your support",
            "How long have you lived here",
            "I am sorry for being late",
            "Have a great day"
        ]

        print("\n" + String(repeating: "=", count: 70))
        print("Full Integration Test - 30 Sentences with All Features")
        print(String(repeating: "=", count: 70))

        var passCount: Int = 0

        for (index, sentence) in sentences.enumerated() {
            let result: String = sut.formatWithProsody(sentence)

            // 기본 검증: 결과가 비어있지 않아야 함
            XCTAssertFalse(result.isEmpty, "[\(index + 1)] Result should not be empty")

            // 검증: thought group separator 외에 공백이 없어야 함
            let withoutThoughtGroups: String = result.replacingOccurrences(of: " / ", with: "")
            let hasUnexpectedSpace: Bool = withoutThoughtGroups.contains(" ")

            if !hasUnexpectedSpace {
                passCount += 1
            }

            XCTAssertFalse(hasUnexpectedSpace,
                "[\(index + 1)] Unexpected space in: '\(result)'")

            print("[\(String(format: "%02d", index + 1))] Input:  \(sentence)")
            print("      Output: \(result)")
            print("      Status: \(hasUnexpectedSpace ? "❌ FAIL" : "✅ PASS")")
            print("")
        }

        print(String(repeating: "=", count: 70))
        print("Results: \(passCount)/\(sentences.count) passed")
        print(String(repeating: "=", count: 70))

        XCTAssertEqual(passCount, sentences.count, "All sentences should pass")
    }

    // MARK: - Edge Cases

    func test_edgeCase_빈문자열() {
        let result: String = sut.format("")
        XCTAssertEqual(result, "", "Empty input should return empty output")
    }

    func test_edgeCase_단일단어() {
        let result: String = sut.format("Hello")
        XCTAssertFalse(result.contains(" "), "Single word should not contain spaces")
        print("Single word: Hello → \(result)")
    }

    func test_edgeCase_숫자포함() {
        let result: String = sut.format("I have 3 apples")
        XCTAssertFalse(result.replacingOccurrences(of: " / ", with: "").contains(" "),
            "Should handle numbers: \(result)")
        print("With numbers: \(result)")
    }

    func test_edgeCase_구두점여러개() {
        let result: String = sut.format("Wait... what?!")
        XCTAssertFalse(result.isEmpty, "Should handle multiple punctuation")
        print("Multiple punctuation: \(result)")
    }

    func test_edgeCase_대문자문장() {
        let result: String = sut.format("I AM VERY HAPPY")
        XCTAssertFalse(result.replacingOccurrences(of: " / ", with: "").contains(" "),
            "Should handle all caps: \(result)")
        print("All caps: \(result)")
    }
}
