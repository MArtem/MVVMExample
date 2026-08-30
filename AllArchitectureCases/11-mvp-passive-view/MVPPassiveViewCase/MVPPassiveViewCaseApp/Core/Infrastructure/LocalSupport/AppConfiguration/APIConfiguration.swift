import Foundation

/// Runtime mode used by app-local infrastructure to distinguish demo-safe behavior from production behavior.
///
/// Invariant:
/// Production runtime must not silently enable demo credentials, fake sessions, or test-only fallbacks.
enum AppRuntimeEnvironment: String, Sendable {
    case demo
    case production
}

/// Explicit error taxonomy for a boundary where silent fallback would hide a supportable failure.
///
/// Map this to localized user-facing copy before rendering errors in SwiftUI.
enum APIConfigurationError: LocalizedError, Equatable, Sendable {
    case missingProductionBaseURL
    case invalidBaseURL(String)

    var errorDescription: String? {
        switch self {
        case .missingProductionBaseURL:
            return "MVP_PASSIVE_VIEW_CASE_API_BASE_URL is required when demo API fallback is disabled."
        case .invalidBaseURL(let value):
            return "Invalid API base URL: \(value)"
        }
    }
}

/// Immutable network/runtime configuration shared by infrastructure clients.
///
/// Responsibilities:
/// - owns base URL, timeout, retry, and demo-credential policy;
/// - reads process environment at composition time;
/// - does not own feature-specific API paths, DTOs, or credentials entered by users.
struct APIConfiguration: Sendable {
    let environment: AppRuntimeEnvironment
    let baseURL: URL
    let requestTimeout: TimeInterval
    let allowsDemoCredentials: Bool
    let retryPolicy: APIRetryPolicy

    init(
        environment: AppRuntimeEnvironment,
        baseURL: URL,
        requestTimeout: TimeInterval,
        allowsDemoCredentials: Bool,
        retryPolicy: APIRetryPolicy
    ) {
        self.environment = environment
        self.baseURL = baseURL
        self.requestTimeout = requestTimeout
        self.allowsDemoCredentials = allowsDemoCredentials
        self.retryPolicy = retryPolicy
    }

    /// Builds configuration from process environment with production-safe defaults outside Debug.
    ///
    /// Invalid explicit base URLs fail fast instead of silently falling back to the demo API.
    /// Tests can exercise URL validation through `makeBaseURL(from:)` without terminating the process.
    ///
    /// External usage:
    /// Called by the app dependency container during startup.
    ///
    /// Environment keys:
    /// - `MVP_PASSIVE_VIEW_CASE_API_BASE_URL`
    /// - `MVP_PASSIVE_VIEW_CASE_API_TIMEOUT_SECONDS`
    /// - `MVP_PASSIVE_VIEW_CASE_ALLOW_DEMO_CREDENTIALS`
    static func current(
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> APIConfiguration {
        do {
            return try make(environment: environment)
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }

    /// Builds configuration from injected environment values for deterministic tests and app composition.
    ///
    /// Missing API base URL is allowed only when demo credentials are allowed. In non-Debug
    /// builds the default is production-safe and requires an explicit valid base URL.
    static func make(environment: [String: String]) throws -> APIConfiguration {
        #if DEBUG
        let defaultAllowsDemoCredentials = true
        #else
        let defaultAllowsDemoCredentials = false
        #endif

        let allowsDemoCredentials = environment["MVP_PASSIVE_VIEW_CASE_ALLOW_DEMO_CREDENTIALS"]
            .map { $0 == "1" || $0.lowercased() == "true" }
            ?? defaultAllowsDemoCredentials

        let baseURL = try makeBaseURL(
            from: environment,
            allowsDemoFallback: allowsDemoCredentials
        )

        let timeout = environment["MVP_PASSIVE_VIEW_CASE_API_TIMEOUT_SECONDS"]
            .flatMap(TimeInterval.init)
            ?? 30

        return APIConfiguration(
            environment: allowsDemoCredentials ? .demo : .production,
            baseURL: baseURL,
            requestTimeout: timeout,
            allowsDemoCredentials: allowsDemoCredentials,
            retryPolicy: .idempotentGET(maxRetries: 2)
        )
    }

    static func makeBaseURL(
        from environment: [String: String],
        allowsDemoFallback: Bool = true
    ) throws -> URL {
        let fallbackDemoURL = URL(string: "https://dummyjson.com")!
        guard let configuredBaseURL = environment["MVP_PASSIVE_VIEW_CASE_API_BASE_URL"] else {
            guard allowsDemoFallback else {
                throw APIConfigurationError.missingProductionBaseURL
            }
            return fallbackDemoURL
        }

        guard
            let url = URL(string: configuredBaseURL),
            let scheme = url.scheme,
            ["http", "https"].contains(scheme.lowercased()),
            url.host?.isEmpty == false
        else {
            throw APIConfigurationError.invalidBaseURL(configuredBaseURL)
        }

        return url
    }
}

/// Explicit demo credential fixture.
///
/// Invariant:
/// These credentials are valid only when `APIConfiguration.allowsDemoCredentials` is true.
struct DemoCredentials: Equatable, Sendable {
    let username: String
    let password: String

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    static let dummyJSON = DemoCredentials(
        username: "emilys",
        password: "emilyspass"
    )
}


/// Retry contract for network clients.
///
/// Rationale:
/// The default policy is limited to idempotent GET requests so user mutations are not retried implicitly.
struct APIRetryPolicy: Sendable, Equatable {
    let maxRetries: Int
    let retryDelay: TimeInterval
    let retriesIdempotentGETOnly: Bool

    init(maxRetries: Int, retryDelay: TimeInterval, retriesIdempotentGETOnly: Bool) {
        self.maxRetries = max(0, maxRetries)
        self.retryDelay = retryDelay
        self.retriesIdempotentGETOnly = retriesIdempotentGETOnly
    }

    static func idempotentGET(maxRetries: Int, retryDelay: TimeInterval = 0.35) -> APIRetryPolicy {
        APIRetryPolicy(
            maxRetries: maxRetries,
            retryDelay: retryDelay,
            retriesIdempotentGETOnly: true
        )
    }
}
