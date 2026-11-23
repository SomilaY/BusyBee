import Foundation

public enum GeminiError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case httpError(Int)
    case decodingError

    public var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Gemini API key is missing. Add GEMINI_API_KEY to your Info.plist."
        case .invalidResponse:
            return "Gemini returned an unexpected response."
        case .httpError(let code):
            return "Gemini HTTP error: \(code)."
        case .decodingError:
            return "Failed to decode Gemini response."
        }
    }
}

public enum GeminiConfig {
    public static var apiKey: String {
        if let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String, !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return key
        }
        return ""
    }
}

public struct GeminiClient {
    private let apiKey: String
    private let model: String
    private let session: URLSession

    public init(apiKey: String = GeminiConfig.apiKey, model: String = "gemini-3.5-flash-lite", session: URLSession = .shared) {
        self.apiKey = apiKey
        self.model = model
        self.session = session
    }

    public func generateText(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else { throw GeminiError.missingAPIKey }
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw GeminiError.invalidResponse }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GeminiGenerateRequest(
            contents: [
                GeminiContent(role: "user", parts: [GeminiPart(text: prompt)])
            ]
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw GeminiError.invalidResponse }
        guard 200..<300 ~= http.statusCode else { throw GeminiError.httpError(http.statusCode) }
        do {
            let decoded = try JSONDecoder().decode(GeminiGenerateResponse.self, from: data)
            if let text = decoded.firstText, !text.isEmpty {
                return text
            } else {
                throw GeminiError.invalidResponse
            }
        } catch {
            throw GeminiError.decodingError
        }
    }
}

private struct GeminiGenerateRequest: Codable {
    let contents: [GeminiContent]
}

private struct GeminiContent: Codable {
    let role: String
    let parts: [GeminiPart]
}

private struct GeminiPart: Codable {
    let text: String
}

private struct GeminiGenerateResponse: Codable {
    struct Candidate: Codable {
        let content: GeminiContent?
        let finishReason: String?
    }
    let candidates: [Candidate]?
}

private extension GeminiGenerateResponse {
    var firstText: String? {
        guard let candidate = candidates?.first, let text = candidate.content?.parts.first?.text else { return nil }
        return text
    }
}
