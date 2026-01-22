import XCTest
@testable import MYPlanner

@MainActor
final class TextComparatorTests: XCTestCase {

    var sut: TextComparator!

    override func setUp() {
        super.setUp()
        sut = TextComparator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Basic Comparison Tests

    func test_compare_identicalText_returns100Percent() {
        let result: TextComparisonResult = sut.compare(
            source: "hello world",
            target: "hello world"
        )

        XCTAssertEqual(result.matchPercentage, 1.0)
        XCTAssertEqual(result.differences.count, 2)
        XCTAssertTrue(result.differences.allSatisfy { $0.type == .match })
    }

    func test_compare_completelyDifferent_returns0Percent() {
        let result: TextComparisonResult = sut.compare(
            source: "hello world",
            target: "foo bar"
        )

        XCTAssertEqual(result.matchPercentage, 0.0)
    }

    func test_compare_partialMatch_returnsCorrectPercentage() {
        // 2 out of 4 words match (I, a)
        let result: TextComparisonResult = sut.compare(
            source: "I am a boy",
            target: "I an a poy"
        )

        XCTAssertEqual(result.matchPercentage, 0.5, accuracy: 0.01)
    }

    func test_compare_emptyStrings_returns100Percent() {
        let result: TextComparisonResult = sut.compare(
            source: "",
            target: ""
        )

        XCTAssertEqual(result.matchPercentage, 1.0)
        XCTAssertTrue(result.differences.isEmpty)
    }

    func test_compare_emptySource_returns0Percent() {
        let result: TextComparisonResult = sut.compare(
            source: "",
            target: "hello"
        )

        XCTAssertEqual(result.matchPercentage, 0.0)
    }

    func test_compare_emptyTarget_returns0Percent() {
        let result: TextComparisonResult = sut.compare(
            source: "hello",
            target: ""
        )

        XCTAssertEqual(result.matchPercentage, 0.0)
    }

    // MARK: - Case Insensitivity Tests

    func test_compare_ignoresCase() {
        let result: TextComparisonResult = sut.compare(
            source: "Hello World",
            target: "hello world"
        )

        XCTAssertEqual(result.matchPercentage, 1.0)
    }

    func test_compare_mixedCase() {
        let result: TextComparisonResult = sut.compare(
            source: "PREPARE for the MEETING",
            target: "prepare for the meeting"
        )

        XCTAssertEqual(result.matchPercentage, 1.0)
    }

    // MARK: - Punctuation Tests

    func test_compare_ignoresPunctuation() {
        let result: TextComparisonResult = sut.compare(
            source: "Hello, world!",
            target: "Hello world"
        )

        XCTAssertEqual(result.matchPercentage, 1.0)
    }

    func test_compare_sentenceWithPunctuation() {
        let result: TextComparisonResult = sut.compare(
            source: "I need to prepare for the meeting.",
            target: "I need to prepare for the meeting"
        )

        XCTAssertEqual(result.matchPercentage, 1.0)
    }

    // MARK: - Difference Type Tests

    func test_compare_detectsSubstitution() {
        let result: TextComparisonResult = sut.compare(
            source: "hello",
            target: "hallo"
        )

        XCTAssertEqual(result.differences.count, 1)
        XCTAssertEqual(result.differences.first?.type, .substitution)
        XCTAssertEqual(result.differences.first?.sourceText, "hello")
        XCTAssertEqual(result.differences.first?.targetText, "hallo")
    }

    func test_compare_detectsInsertion() {
        let result: TextComparisonResult = sut.compare(
            source: "hello world",
            target: "hello um world"
        )

        let insertions: [TextDifference] = result.differences.filter { $0.type == .insertion }
        XCTAssertEqual(insertions.count, 1)
        XCTAssertEqual(insertions.first?.targetText, "um")
    }

    func test_compare_detectsDeletion() {
        let result: TextComparisonResult = sut.compare(
            source: "hello beautiful world",
            target: "hello world"
        )

        let deletions: [TextDifference] = result.differences.filter { $0.type == .deletion }
        XCTAssertEqual(deletions.count, 1)
        XCTAssertEqual(deletions.first?.sourceText, "beautiful")
    }

    // MARK: - Real Sentence Tests

    func test_compare_realSentence_prepareForMeeting() {
        let result: TextComparisonResult = sut.compare(
            source: "Prepare for the meeting",
            target: "Prepare for the meeting"
        )

        XCTAssertEqual(result.matchPercentage, 1.0)
    }

    func test_compare_realSentence_withMispronunciation() {
        let result: TextComparisonResult = sut.compare(
            source: "Prepare for the product meeting",
            target: "Prepare for the project meeting"
        )

        // 4 out of 5 words match
        XCTAssertEqual(result.matchPercentage, 0.8, accuracy: 0.01)
    }

    func test_compare_realSentence_withMissingWord() {
        let result: TextComparisonResult = sut.compare(
            source: "I need to prepare for the meeting",
            target: "I need to prepare the meeting"
        )

        // 6 out of 7 words match
        let deletions: [TextDifference] = result.differences.filter { $0.type == .deletion }
        XCTAssertEqual(deletions.count, 1)
        XCTAssertEqual(deletions.first?.sourceText, "for")
    }

    func test_compare_realSentence_withExtraWord() {
        let result: TextComparisonResult = sut.compare(
            source: "Prepare for the meeting",
            target: "Prepare well for the meeting"
        )

        let insertions: [TextDifference] = result.differences.filter { $0.type == .insertion }
        XCTAssertEqual(insertions.count, 1)
        XCTAssertEqual(insertions.first?.targetText, "well")
    }

    // MARK: - Edge Cases

    func test_compare_singleWord_match() {
        let result: TextComparisonResult = sut.compare(
            source: "hello",
            target: "hello"
        )

        XCTAssertEqual(result.matchPercentage, 1.0)
    }

    func test_compare_singleWord_noMatch() {
        let result: TextComparisonResult = sut.compare(
            source: "hello",
            target: "world"
        )

        XCTAssertEqual(result.matchPercentage, 0.0)
    }

    func test_compare_extraSpaces_ignored() {
        let result: TextComparisonResult = sut.compare(
            source: "hello   world",
            target: "hello world"
        )

        XCTAssertEqual(result.matchPercentage, 1.0)
    }
}
