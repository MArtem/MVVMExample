import Foundation

/// Stable API/network error taxonomy used across app infrastructure.
///
/// Boundary rule:
/// Technical details can be logged, but UI should map these cases through a host-app error mapper instead of showing raw `localizedDescription`.
enum AppAPIError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case offline
    case timeout
    case cancelled
    case unauthorized(String?)
    case forbidden(String?)
    case server(statusCode: Int, message: String?)
    case encoding(String)
    case decoding(String)
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid server response."
        case .offline:
            return "The internet connection appears to be offline."
        case .timeout:
            return "The request timed out."
        case .cancelled:
            return "The request was cancelled."
        case .unauthorized(let message):
            return message ?? "Authentication expired."
        case .forbidden(let message):
            return message ?? "You do not have permission to perform this action."
        case .server(let statusCode, let message):
            return message ?? "Request failed with status code \(statusCode)."
        case .encoding(let message):
            return "Encoding failed: \(message)"
        case .decoding(let message):
            return "Decoding failed: \(message)"
        case .transport(let message):
            return message
        }
    }
}
