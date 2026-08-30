import Foundation

typealias APIError = AppAPIError

/// App-owned bridge from runtime API configuration to app-local networking configuration.
///
/// Rationale:
/// Product/runtime configuration is adapted at this app boundary so feature repositories depend on one local `APIClient` contract.
extension APIConfiguration {
    var networkClientConfiguration: NetworkClientConfiguration {
        NetworkClientConfiguration(
            baseURL: baseURL,
            requestTimeout: requestTimeout,
            retryPolicy: retryPolicy.networkRetryPolicy
        )
    }
}

private extension APIRetryPolicy {
    var networkRetryPolicy: NetworkRetryPolicy {
        NetworkRetryPolicy(
            maxRetries: maxRetries,
            retryDelay: retryDelay,
            retriesIdempotentGETOnly: retriesIdempotentGETOnly
        )
    }
}

/// App-owned bridge from network failures to the app error taxonomy.
///
/// External usage:
/// Inject into `URLSessionNetworkClient` during app dependency composition so feature Models continue to receive `AppAPIError`.
extension NetworkErrorMapping {
    static let appAPIError = NetworkErrorMapping(
        invalidURL: { AppAPIError.invalidURL },
        invalidResponse: { AppAPIError.invalidResponse },
        unauthorized: { AppAPIError.unauthorized($0) },
        forbidden: { AppAPIError.forbidden($0) },
        server: { AppAPIError.server(statusCode: $0, message: $1) },
        encoding: { AppAPIError.encoding($0) },
        decoding: { AppAPIError.decoding($0) },
        cancelled: { AppAPIError.cancelled },
        urlError: { error in
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost:
                return AppAPIError.offline
            case .timedOut:
                return AppAPIError.timeout
            case .cancelled:
                return AppAPIError.cancelled
            default:
                return AppAPIError.transport(error.localizedDescription)
            }
        },
        transport: { AppAPIError.transport($0) },
        shouldRetry: { error in
            guard let apiError = error as? AppAPIError else { return false }
            switch apiError {
            case .offline, .timeout, .transport, .server:
                return true
            case .cancelled, .unauthorized, .forbidden, .encoding, .decoding, .invalidResponse, .invalidURL:
                return false
            }
        }
    )
}

/// Converts technical errors into stable user-facing localized messages.
///
/// Responsibilities:
/// - hide transport/DTO details from UI;
/// - keep supportable message categories stable across networking implementations.
enum AppErrorMapper {
    static func userMessage(for error: Error) -> String {
        guard let apiError = error as? AppAPIError else {
            return AppStrings.text("Something went wrong. Please try again.")
        }

        switch apiError {
        case .offline:
            return AppStrings.text("You appear to be offline. Check your connection and try again.")
        case .timeout:
            return AppStrings.text("The request took too long. Please try again.")
        case .cancelled:
            return AppStrings.text("The request was cancelled.")
        case .unauthorized:
            return AppStrings.text("Your session expired. Please sign in again.")
        case .forbidden:
            return AppStrings.text("You don’t have permission to perform this action.")
        case .server:
            return AppStrings.text("The server could not complete the request. Please try again.")
        case .encoding, .decoding, .invalidResponse, .invalidURL:
            return AppStrings.text("We couldn’t process the server response. Please try again later.")
        case .transport:
            return AppStrings.text("The network request failed. Please try again.")
        }
    }
}
