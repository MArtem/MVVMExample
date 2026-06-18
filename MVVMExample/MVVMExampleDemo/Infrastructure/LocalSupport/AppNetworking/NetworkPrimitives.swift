import Foundation

public enum NetworkHTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Retry contract for `URLSessionNetworkClient`.
///
/// Boundary rule:
/// The package owns retry mechanics, while host apps decide which concrete errors are retryable through `NetworkErrorMapping`.
public struct NetworkRetryPolicy: Sendable, Equatable {
    public let maxRetries: Int
    public let retryDelay: TimeInterval
    public let retriesIdempotentGETOnly: Bool

    public init(maxRetries: Int, retryDelay: TimeInterval, retriesIdempotentGETOnly: Bool) {
        self.maxRetries = max(0, maxRetries)
        self.retryDelay = retryDelay
        self.retriesIdempotentGETOnly = retriesIdempotentGETOnly
    }

    public static func idempotentGET(maxRetries: Int, retryDelay: TimeInterval = 0.35) -> NetworkRetryPolicy {
        NetworkRetryPolicy(
            maxRetries: maxRetries,
            retryDelay: retryDelay,
            retriesIdempotentGETOnly: true
        )
    }
}

/// Standalone network runtime configuration.
///
/// Ownership:
/// Host apps construct this value from their environment/configuration package. `AppNetworking` intentionally does not depend on app configuration modules.
public struct NetworkClientConfiguration: Sendable, Equatable {
    public let baseURL: URL
    public let requestTimeout: TimeInterval
    public let retryPolicy: NetworkRetryPolicy

    public init(baseURL: URL, requestTimeout: TimeInterval, retryPolicy: NetworkRetryPolicy) {
        self.baseURL = baseURL
        self.requestTimeout = requestTimeout
        self.retryPolicy = retryPolicy
    }
}

/// Package-local network error taxonomy used when no host-app mapper is supplied.
///
/// Host apps that own a richer domain error can inject `NetworkErrorMapping` and keep this type at the package boundary.
public enum NetworkClientError: LocalizedError, Equatable, Sendable {
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

    public var errorDescription: String? {
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

/// Error composition hook that keeps `AppNetworking` standalone while allowing app-owned error types.
///
/// External usage:
/// Apps that have their own error taxonomy create one mapper at composition time and inject it into `URLSessionNetworkClient`.
public struct NetworkErrorMapping: Sendable {
    public let invalidURL: @Sendable () -> any Error
    public let invalidResponse: @Sendable () -> any Error
    public let unauthorized: @Sendable (_ message: String?) -> any Error
    public let forbidden: @Sendable (_ message: String?) -> any Error
    public let server: @Sendable (_ statusCode: Int, _ message: String?) -> any Error
    public let encoding: @Sendable (_ message: String) -> any Error
    public let decoding: @Sendable (_ message: String) -> any Error
    public let cancelled: @Sendable () -> any Error
    public let urlError: @Sendable (_ error: URLError) -> any Error
    public let transport: @Sendable (_ message: String) -> any Error
    public let shouldRetry: @Sendable (_ error: any Error) -> Bool

    public init(
        invalidURL: @escaping @Sendable () -> any Error,
        invalidResponse: @escaping @Sendable () -> any Error,
        unauthorized: @escaping @Sendable (_ message: String?) -> any Error,
        forbidden: @escaping @Sendable (_ message: String?) -> any Error,
        server: @escaping @Sendable (_ statusCode: Int, _ message: String?) -> any Error,
        encoding: @escaping @Sendable (_ message: String) -> any Error,
        decoding: @escaping @Sendable (_ message: String) -> any Error,
        cancelled: @escaping @Sendable () -> any Error,
        urlError: @escaping @Sendable (_ error: URLError) -> any Error,
        transport: @escaping @Sendable (_ message: String) -> any Error,
        shouldRetry: @escaping @Sendable (_ error: any Error) -> Bool
    ) {
        self.invalidURL = invalidURL
        self.invalidResponse = invalidResponse
        self.unauthorized = unauthorized
        self.forbidden = forbidden
        self.server = server
        self.encoding = encoding
        self.decoding = decoding
        self.cancelled = cancelled
        self.urlError = urlError
        self.transport = transport
        self.shouldRetry = shouldRetry
    }

    public static let networkClientError = NetworkErrorMapping(
        invalidURL: { NetworkClientError.invalidURL },
        invalidResponse: { NetworkClientError.invalidResponse },
        unauthorized: { NetworkClientError.unauthorized($0) },
        forbidden: { NetworkClientError.forbidden($0) },
        server: { NetworkClientError.server(statusCode: $0, message: $1) },
        encoding: { NetworkClientError.encoding($0) },
        decoding: { NetworkClientError.decoding($0) },
        cancelled: { NetworkClientError.cancelled },
        urlError: { error in
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost:
                return NetworkClientError.offline
            case .timedOut:
                return NetworkClientError.timeout
            case .cancelled:
                return NetworkClientError.cancelled
            default:
                return NetworkClientError.transport(error.localizedDescription)
            }
        },
        transport: { NetworkClientError.transport($0) },
        shouldRetry: { error in
            guard let networkError = error as? NetworkClientError else { return false }
            switch networkError {
            case .offline, .timeout, .transport, .server:
                return true
            case .cancelled, .unauthorized, .forbidden, .encoding, .decoding, .invalidResponse, .invalidURL:
                return false
            }
        }
    )
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
/// Implementations preserve cancellation behavior and either throw `NetworkClientError` or host-app errors supplied through `NetworkErrorMapping`.
public protocol NetworkClient {
    func send<Response: Decodable>(_ request: NetworkRequest) async throws -> Response
}
