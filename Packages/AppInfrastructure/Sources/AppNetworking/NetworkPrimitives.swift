import Foundation

public enum NetworkHTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Value contract for one HTTP request understood by `NetworkClient`.
///
/// Responsibilities:
/// - provide path, method, query, headers, and an optional throwing body encoder;
/// - avoid hiding body-encoding failures.
public protocol NetworkRequest {
    var path: String { get }
    var method: NetworkHTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    func makeBody() throws -> Data?
}

public extension NetworkRequest {
    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    func makeBody() throws -> Data? { nil }
}

/// Generic async network boundary for typed Decodable responses.
///
/// Errors:
/// Implementations should map known failures to `AppAPIError` and preserve cancellation behavior.
public protocol NetworkClient {
    func send<Response: Decodable>(_ request: NetworkRequest) async throws -> Response
}
