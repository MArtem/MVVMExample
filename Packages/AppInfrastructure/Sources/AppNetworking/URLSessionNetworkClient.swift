import Foundation

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

    public func send<Response: Decodable>(_ request: NetworkRequest) async throws -> Response {
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
        do {
            urlRequest.httpBody = try request.makeBody()
        } catch {
            throw AppAPIError.encoding(error.localizedDescription)
        }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        logger.log("HTTP \(request.method.rawValue) \(url.absoluteString)")

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
}

private struct APIMessageDTO: Decodable {
    let message: String?
}
