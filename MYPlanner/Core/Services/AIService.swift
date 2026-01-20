//
//  AIService.swift
//  MYPlanner
//
//  Step 9: Claude API Integration
//

import Foundation

// MARK: - Protocol for Dependency Injection

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

// MARK: - Error Types

enum AIServiceError: Error, LocalizedError {
    case noAPIKey
    case invalidResponse
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "API key not configured"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return message
        }
    }
}

// MARK: - AIService

struct AIService {

    // MARK: - Properties

    private let session: URLSessionProtocol
    private let keychain: KeychainService
    private let baseURL = "https://kdt-api-function.azurewebsites.net/api/v1/question"
    private let model = "claude-sonnet-4-20250514"

    // MARK: - Initialization

    init(
        session: URLSessionProtocol = URLSession.shared,
        keychain: KeychainService = KeychainService()
    ) {
        self.session = session
        self.keychain = keychain
    }

    // MARK: - Public Methods

    func generateExpression(for schedule: String) async throws -> String {
        guard let apiKey = keychain.retrieveAPIKey() else {
            throw AIServiceError.noAPIKey
        }

        let request = try buildRequest(for: schedule, apiKey: apiKey)
        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw AIServiceError.apiError("HTTP \(httpResponse.statusCode)")
        }

        let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)

        guard let text = claudeResponse.content.first?.text else {
            throw AIServiceError.invalidResponse
        }

        return text
    }

    // MARK: - Private Methods

    private func buildRequest(for schedule: String, apiKey: String) throws -> URLRequest {
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        let prompt = """
        일정: \(schedule)

        위 일정에 대해 영어로 표현하는 문장을 1개만 생성해주세요.
        악센트 표시 포함 (예: pre-PARE for the MEET-ing)
        문장만 출력하세요.
        """

        let body = ClaudeRequest(
            model: model,
            maxTokens: 256,
            messages: [.init(role: "user", content: prompt)]
        )

        request.httpBody = try JSONEncoder().encode(body)

        return request
    }
}

// MARK: - Request/Response Models

private struct ClaudeRequest: Encodable {
    let model: String
    let maxTokens: Int
    let messages: [Message]

    struct Message: Encodable {
        let role: String
        let content: String
    }

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case messages
    }
}

private struct ClaudeResponse: Decodable {
    let content: [Content]

    struct Content: Decodable {
        let type: String
        let text: String
    }
}
