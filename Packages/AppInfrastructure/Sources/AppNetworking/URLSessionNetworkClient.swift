import Foundation
import AppConfiguration
import AppErrors
import AppLogging

/// URLSession-backed implementation of `NetworkClient`.
///
/// Responsibilities:
/// - composes requests against `APIConfiguration.baseURL`;
/// - applies timeout and retry policy;
/// - maps transport, HTTP, encoding, and decoding failures to `AppAPIError`;
/// - logs only redacted request metadata.
///
/// Concurrency:
/// Individual requests are cancellable through Swift concurrency. Cancellation is surfaced as `AppAPIError.cancelled`.
public final class URLSessionNetworkClient: NetworkClient {
    private let configuration: APIConfiguration
    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger: AppLogger

    public init(
        configuration: APIConfiguration,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        logger: AppLogger = NoOpAppLogger()
    ) {
        self.configuration = configuration
        self.session = session
        self.decoder = decoder
        self.logger = logger
    }

    /// Sends one typed network request and decodes its response.
    ///
    /// Errors:
    /// Throws `AppAPIError` for known API/transport failures and preserves cancellation semantics.
    ///
    /// Side effects:
    /// May perform bounded retries for idempotent GET requests according to configuration.
    public func send<Response: Decodable>(_ request: NetworkRequest) async throws -> Response {
        var attempt = 0
        while true {
            do {
                return try await perform(request)
            } catch {
                guard shouldRetry(request: request, error: error, attempt: attempt) else {
                    throw error
                }
                attempt += 1
                try await Task.sleep(for: .seconds(configuration.retryPolicy.retryDelay))
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
            throw AppAPIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = configuration.requestTimeout
        do {
            urlRequest.httpBody = try request.makeBody()
        } catch {
            throw AppAPIError.encoding(error.localizedDescription)
        }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        logger.log("HTTP \(request.method.rawValue) \(redactedURLString(url))")

        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppAPIError.invalidResponse
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
                throw AppAPIError.decoding(error.localizedDescription)
            }
        } catch let error as AppAPIError {
            throw error
        } catch is CancellationError {
            throw AppAPIError.cancelled
        } catch let error as URLError {
            throw mapURLError(error)
        } catch {
            throw AppAPIError.transport(error.localizedDescription)
        }
    }

    private func shouldRetry(request: NetworkRequest, error: Error, attempt: Int) -> Bool {
        guard attempt < configuration.retryPolicy.maxRetries else { return false }
        if configuration.retryPolicy.retriesIdempotentGETOnly && request.method != .get {
            return false
        }
        guard let apiError = error as? AppAPIError else { return false }
        switch apiError {
        case .offline, .timeout, .transport, .server:
            return true
        case .cancelled, .unauthorized, .forbidden, .encoding, .decoding, .invalidResponse, .invalidURL:
            return false
        }
    }

    private func mapStatusCode(_ statusCode: Int, message: String?) -> AppAPIError {
        switch statusCode {
        case 401:
            return .unauthorized(message)
        case 403:
            return .forbidden(message)
        default:
            return .server(statusCode: statusCode, message: message)
        }
    }

    private func mapURLError(_ error: URLError) -> AppAPIError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost:
            return .offline
        case .timedOut:
            return .timeout
        case .cancelled:
            return .cancelled
        default:
            return .transport(error.localizedDescription)
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

private struct APIMessageDTO: Decodable {
    let message: String?
}
