//
//  AIServiceTests.swift
//  MYPlannerTests
//
//  Step 9: TDD for AIService
//

import XCTest
@testable import MYPlanner

// MARK: - Mock Classes

class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }

        let data = mockData ?? Data()
        let response = mockResponse ?? HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        return (data, response)
    }
}

class MockKeychainService {
    var apiKey: String?

    func retrieveAPIKey() -> String? {
        return apiKey
    }

    var hasAPIKey: Bool {
        return apiKey != nil
    }
}

// MARK: - AIService Tests

final class AIServiceTests: XCTestCase {

    var sut: AIService!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        // Use real KeychainService with test service identifier
        let testKeychain = KeychainService(service: "com.myplanner.test")
        testKeychain.saveAPIKey("733bbc26-8cb9-48ed-a7ce-862e6d9001f0")
        sut = AIService(session: mockSession, keychain: testKeychain)
    }

    override func tearDown() {
        let testKeychain = KeychainService(service: "com.myplanner.test")
        testKeychain.deleteAPIKey()
        sut = nil
        mockSession = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_withDependencies_succeeds() {
        // Assert
        XCTAssertNotNil(sut)
    }

    // MARK: - Generate Expression Tests

    func test_generateExpression_withValidInput_returnsExpression() async throws {
        // Arrange
        let mockResponseJSON = """
        {
            "content": [
                {
                    "type": "text",
                    "text": "I need to pre-PARE for the MEET-ing."
                }
            ]
        }
        """
        mockSession.mockData = mockResponseJSON.data(using: .utf8)

        // Act
        let result = try await sut.generateExpression(for: "회의 준비")

        // Assert
        XCTAssertEqual(result, "I need to pre-PARE for the MEET-ing.")
    }

    func test_generateExpression_withNoAPIKey_throwsError() async {
        // Arrange
        let testKeychain = await KeychainService(service: "com.myplanner.test")
        await testKeychain.deleteAPIKey()
        sut = await AIService(session: mockSession, keychain: testKeychain)

        // Act & Assert
        do {
            _ = try await sut.generateExpression(for: "회의 준비")
            XCTFail("Expected error to be thrown")
        } catch AIServiceError.noAPIKey {
            // Success - expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_generateExpression_withNetworkError_throwsError() async {
        // Arrange
        mockSession.mockError = URLError(.notConnectedToInternet)

        // Act & Assert
        do {
            _ = try await sut.generateExpression(for: "회의 준비")
            XCTFail("Expected error to be thrown")
        } catch is URLError {
            // Success - expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_generateExpression_with401Error_throwsAPIError() async {
        // Arrange
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.anthropic.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        mockSession.mockData = """
        {"error": {"message": "Invalid API key"}}
        """.data(using: .utf8)

        // Act & Assert
        do {
            _ = try await sut.generateExpression(for: "테스트")
            XCTFail("Expected error")
        } catch AIServiceError.apiError(let message) {
            XCTAssertTrue(message.contains("401"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_generateExpression_withInvalidJSON_throwsError() async {
        // Arrange
        mockSession.mockData = "invalid json".data(using: .utf8)

        // Act & Assert
        do {
            _ = try await sut.generateExpression(for: "테스트")
            XCTFail("Expected error")
        } catch is DecodingError {
            // Success - expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_generateExpression_withEmptyContent_throwsInvalidResponse() async {
        // Arrange
        let mockResponseJSON = """
        {
            "content": []
        }
        """
        mockSession.mockData = mockResponseJSON.data(using: .utf8)

        // Act & Assert
        do {
            _ = try await sut.generateExpression(for: "테스트")
            XCTFail("Expected error")
        } catch AIServiceError.invalidResponse {
            // Success - expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
