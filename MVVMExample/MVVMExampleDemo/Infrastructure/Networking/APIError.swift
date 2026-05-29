import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case badStatusCode(Int, String?)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid server response."
        case .badStatusCode(let code, let message):
            return message ?? "Request failed with status code \(code)."
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        }
    }
}
