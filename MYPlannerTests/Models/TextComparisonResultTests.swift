import XCTest
@testable import MYPlanner

@MainActor
final class TextComparisonResultTests: XCTestCase {

    func test_textComparisonResult_initialization() {
        let differences: [TextDifference] = []
        let result: TextComparisonResult = TextComparisonResult(
            differences: differences,
            matchPercentage: 1.0
        )

        XCTAssertTrue(result.differences.isEmpty)
        XCTAssertEqual(result.matchPercentage, 1.0)
    }

    func test_textComparisonResult_withDifferences() {
        let diff: TextDifference = TextDifference(
            type: .substitution,
            sourceText: "hello",
            targetText: "hallo"
        )
        let result: TextComparisonResult = TextComparisonResult(
            differences: [diff],
            matchPercentage: 0.5
        )

        XCTAssertEqual(result.differences.count, 1)
        XCTAssertEqual(result.matchPercentage, 0.5)
    }
}

// MARK: - TextDifference Tests

@MainActor
final class TextDifferenceTests: XCTestCase {

    func test_textDifference_match() {
        let diff: TextDifference = TextDifference(
            type: .match,
            sourceText: "hello",
            targetText: "hello"
        )

        XCTAssertEqual(diff.type, .match)
        XCTAssertEqual(diff.sourceText, diff.targetText)
    }

    func test_textDifference_substitution() {
        let diff: TextDifference = TextDifference(
            type: .substitution,
            sourceText: "am",
            targetText: "an"
        )

        XCTAssertEqual(diff.type, .substitution)
        XCTAssertNotEqual(diff.sourceText, diff.targetText)
    }

    func test_textDifference_insertion() {
        let diff: TextDifference = TextDifference(
            type: .insertion,
            sourceText: "",
            targetText: "um"
        )

        XCTAssertEqual(diff.type, .insertion)
        XCTAssertTrue(diff.sourceText.isEmpty)
    }

    func test_textDifference_deletion() {
        let diff: TextDifference = TextDifference(
            type: .deletion,
            sourceText: "the",
            targetText: ""
        )

        XCTAssertEqual(diff.type, .deletion)
        XCTAssertTrue(diff.targetText.isEmpty)
    }
}

// MARK: - DifferenceType Tests

@MainActor
final class DifferenceTypeTests: XCTestCase {

    func test_differenceType_allCases() {
        let allCases: [DifferenceType] = [.match, .substitution, .insertion, .deletion]
        XCTAssertEqual(allCases.count, 4)
    }
}
