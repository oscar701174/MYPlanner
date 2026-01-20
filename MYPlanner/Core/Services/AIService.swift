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
        guard let apiKey = keychain.retrieveAPIKey()?.trimmingCharacters(in: .whitespacesAndNewlines),
              !apiKey.isEmpty else {
            print("🔴 [AIService] No API key found")
            throw AIServiceError.noAPIKey
        }

        print("🟡 [AIService] Generating expression for: \(schedule)")

        let request = try buildRequest(for: schedule, apiKey: apiKey)
        let (data, response) = try await session.data(for: request)

        // Debug: Print raw response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🟢 [AIService] Raw Response: \(jsonString)")
        }

        if let httpResponse = response as? HTTPURLResponse {
            print("🔵 [AIService] HTTP Status: \(httpResponse.statusCode)")
            if !(200...299).contains(httpResponse.statusCode) {
                throw AIServiceError.apiError("HTTP \(httpResponse.statusCode)")
            }
        }

        // Try to parse response - handle different formats
        let text: String

        // Debug: Print all keys in JSON
        if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("🟣 [AIService] JSON keys: \(jsonObject.keys)")
        }

        // First try: Claude format with content array
        if let claudeResponse = try? JSONDecoder().decode(ClaudeResponse.self, from: data),
           let content = claudeResponse.content.first?.text {
            text = content
        }
        // Second try: Simple response with common field names
        else if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let content = jsonObject["content"] as? String {
                text = content
            } else if let answer = jsonObject["answer"] as? String {
                text = answer
            } else if let response = jsonObject["response"] as? String {
                text = response
            } else if let message = jsonObject["message"] as? String {
                text = message
            } else if let result = jsonObject["result"] as? String {
                text = result
            } else if let data = jsonObject["data"] as? String {
                text = data
            } else if let output = jsonObject["output"] as? String {
                text = output
            } else {
                print("🔴 [AIService] Unknown JSON format: \(jsonObject)")
                throw AIServiceError.invalidResponse
            }
        }
        // Third try: Plain text response
        else if let plainText = String(data: data, encoding: .utf8), !plainText.isEmpty {
            text = plainText
        }
        else {
            print("🔴 [AIService] Could not parse response")
            throw AIServiceError.invalidResponse
        }

        print("✅ [AIService] Generated: \(text)")
        return text
    }

    // MARK: - Private Methods

    private func buildRequest(for schedule: String, apiKey: String) throws -> URLRequest {
        // Build content query matching Postman format
        let content = "category:\(schedule), 할일: \(schedule), 이런 상황에서 유용한 영어표현 5개. 영어문장만"

        // Build URL with query parameters
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "content", value: content),
            URLQueryItem(name: "client_id", value: apiKey)
        ]

        guard let url = components?.url else {
            throw AIServiceError.invalidResponse
        }

        print("🔵 [AIService] Request URL: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

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
