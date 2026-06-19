import Foundation

enum NetworkHTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Retry contract for `URLSessionNetworkClient`.
///
/// Boundary rule:
/// LocalSupport owns retry mechanics, while app composition decides which concrete errors are retryable through `NetworkErrorMapping`.
struct NetworkRetryPolicy: Sendable, Equatable {
    let maxRetries: Int
    let retryDelay: TimeInterval
    let retriesIdempotentGETOnly: Bool

    init(maxRetries: Int, retryDelay: TimeInterval, retriesIdempotentGETOnly: Bool) {
        self.maxRetries = max(0, maxRetries)
        self.retryDelay = retryDelay
        self.retriesIdempotentGETOnly = retriesIdempotentGETOnly
    }

    static func idempotentGET(maxRetries: Int, retryDelay: TimeInterval = 0.35) -> NetworkRetryPolicy {
        NetworkRetryPolicy(
            maxRetries: maxRetries,
            retryDelay: retryDelay,
            retriesIdempotentGETOnly: true
        )
    }
}

/// App-local network runtime configuration.
///
/// Ownership:
/// App composition constructs this value from `APIConfiguration`; network primitives stay independent from feature-specific DTOs and routes.
struct NetworkClientConfiguration: Sendable, Equatable {
    let baseURL: URL
    let requestTimeout: TimeInterval
    let retryPolicy: NetworkRetryPolicy

    init(baseURL: URL, requestTimeout: TimeInterval, retryPolicy: NetworkRetryPolicy) {
        self.baseURL = baseURL
        self.requestTimeout = requestTimeout
        self.retryPolicy = retryPolicy
    }
}

/// LocalSupport network error taxonomy used when no app-specific mapper is supplied.
///
/// App composition can inject `NetworkErrorMapping` to keep UI-facing errors in the app error taxonomy.
enum NetworkClientError: LocalizedError, Equatable, Sendable {
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

/// Error composition hook that keeps networking mechanics decoupled from app-owned UI error mapping.
///
/// External usage:
/// The app creates one mapper at composition time and injects it into `URLSessionNetworkClient`.
struct NetworkErrorMapping: Sendable {
    let invalidURL: @Sendable () -> any Error
    let invalidResponse: @Sendable () -> any Error
    let unauthorized: @Sendable (_ message: String?) -> any Error
    let forbidden: @Sendable (_ message: String?) -> any Error
    let server: @Sendable (_ statusCode: Int, _ message: String?) -> any Error
    let encoding: @Sendable (_ message: String) -> any Error
    let decoding: @Sendable (_ message: String) -> any Error
    let cancelled: @Sendable () -> any Error
    let urlError: @Sendable (_ error: URLError) -> any Error
    let transport: @Sendable (_ message: String) -> any Error
    let shouldRetry: @Sendable (_ error: any Error) -> Bool

    init(
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

    static let networkClientError = NetworkErrorMapping(
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
protocol NetworkRequest {
    var path: String { get }
    var method: NetworkHTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    func makeBody() throws -> Data?
}

extension NetworkRequest {
    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    func makeBody() throws -> Data? { nil }
}

/// Generic async network boundary for typed Decodable responses.
///
/// Errors:
/// Implementations preserve cancellation behavior and either throw `NetworkClientError` or host-app errors supplied through `NetworkErrorMapping`.
protocol NetworkClient {
    func send<Response: Decodable>(_ request: NetworkRequest) async throws -> Response
}
