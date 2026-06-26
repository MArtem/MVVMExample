import Foundation

/// Performs a retry delay requested by `NetworkRetryPolicy`.
typealias NetworkRetrySleeper = @Sendable (_ delaySeconds: TimeInterval) async throws -> Void

/// URLSession-backed implementation of `NetworkClient`.
///
/// Responsibilities:
/// - composes requests against `NetworkClientConfiguration.baseURL`;
/// - applies timeout and retry policy;
/// - maps transport, HTTP, encoding, and decoding failures through an injected `NetworkErrorMapping`;
/// - logs only redacted request metadata through an injected sendable closure.
///
/// Concurrency:
/// Individual requests are cancellable through Swift concurrency. Cancellation is surfaced through the configured error mapper.
final class URLSessionNetworkClient: NetworkClient {
    private let configuration: NetworkClientConfiguration
    private let session: URLSession
    private let decoder: JSONDecoder
    private let log: @Sendable (_ message: String) -> Void
    private let errorMapping: NetworkErrorMapping
    private let retrySleeper: NetworkRetrySleeper

    init(
        configuration: NetworkClientConfiguration,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        logger: @escaping @Sendable (_ message: String) -> Void = { _ in },
        errorMapping: NetworkErrorMapping = .networkClientError,
        retrySleeper: @escaping NetworkRetrySleeper = { delaySeconds in
            try await Task.sleep(nanoseconds: UInt64(max(0, delaySeconds) * 1_000_000_000))
        }
    ) {
        self.configuration = configuration
        self.session = session
        self.decoder = decoder
        self.log = logger
        self.errorMapping = errorMapping
        self.retrySleeper = retrySleeper
    }

    /// Sends one typed network request and decodes its response.
    ///
    /// Errors:
    /// Throws mapped known API/transport failures and preserves cancellation semantics.
    ///
    /// Side effects:
    /// May perform bounded retries for idempotent GET requests according to configuration.
    func send<Response: Decodable>(_ request: NetworkRequest) async throws -> Response {
        var attempt = 0
        while true {
            do {
                return try await perform(request)
            } catch {
                guard shouldRetry(request: request, error: error, attempt: attempt) else {
                    throw error
                }
                attempt += 1
                try await retrySleeper(configuration.retryPolicy.retryDelay)
            }
        }
    }

    private func perform<Response: Decodable>(_ request: NetworkRequest) async throws -> Response {
        var components = URLComponents(
            url: configuration.baseURL.appendingPathComponent(request.path),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = request.queryItems.isEmpty ? nil : request.queryItems

        guard let url = components?.url else {
            throw errorMapping.invalidURL()
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = configuration.requestTimeout
        do {
            urlRequest.httpBody = try request.makeBody()
        } catch {
            throw errorMapping.encoding(error.localizedDescription)
        }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        log("HTTP \(request.method.rawValue) \(redactedURLString(url))")

        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw errorMapping.invalidResponse()
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                let message: String?
                do {
                    message = try decoder.decode(APIMessageDTO.self, from: data).message
                } catch {
                    message = nil
                }
                throw mapStatusCode(httpResponse.statusCode, message: message)
            }

            do {
                return try decoder.decode(Response.self, from: data)
            } catch {
                throw errorMapping.decoding(error.localizedDescription)
            }
        } catch is CancellationError {
            throw errorMapping.cancelled()
        } catch let error as URLError {
            throw errorMapping.urlError(error)
        } catch let error as NetworkClientError {
            throw error
        } catch {
            throw error
        }
    }

    private func shouldRetry(request: NetworkRequest, error: any Error, attempt: Int) -> Bool {
        guard attempt < configuration.retryPolicy.maxRetries else { return false }
        if configuration.retryPolicy.retriesIdempotentGETOnly && request.method != .get {
            return false
        }
        return errorMapping.shouldRetry(error)
    }

    private func mapStatusCode(_ statusCode: Int, message: String?) -> any Error {
        switch statusCode {
        case 401:
            return errorMapping.unauthorized(message)
        case 403:
            return errorMapping.forbidden(message)
        default:
            return errorMapping.server(statusCode, message)
        }
    }

    /// Returns a log-safe URL representation while preserving enough path/query shape for debugging.
    private func redactedURLString(_ url: URL) -> String {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return "<redacted-url>"
        }
        let sensitiveQueryNames = Set(["token", "access_token", "refresh_token", "password", "api_key", "key", "secret", "authorization"])
        components.queryItems = components.queryItems?.map { item in
            guard sensitiveQueryNames.contains(item.name.lowercased()) else { return item }
            return URLQueryItem(name: item.name, value: "<redacted>")
        }
        components.user = nil
        components.password = nil
        return components.string ?? "<redacted-url>"
    }
}

/// Transport payload owned by the data/API boundary.
///
/// Mapping responsibility: keep backend optionality, naming, and wire-format quirks here so domain and presentation models stay transport-independent.
private struct APIMessageDTO: Decodable {
    let message: String?
}
