import Foundation

/// Runtime mode used by reusable infrastructure to distinguish demo-safe behavior from production behavior.
///
/// Invariant:
/// Production runtime must not silently enable demo credentials, fake sessions, or test-only fallbacks.
public enum AppRuntimeEnvironment: String, Sendable {
    case demo
    case production
}

/// Immutable network/runtime configuration shared by infrastructure clients.
///
/// Responsibilities:
/// - owns base URL, timeout, retry, and demo-credential policy;
/// - reads process environment at composition time;
/// - does not own feature-specific API paths, DTOs, or credentials entered by users.
public struct APIConfiguration: Sendable {
    public let environment: AppRuntimeEnvironment
    public let baseURL: URL
    public let requestTimeout: TimeInterval
    public let allowsDemoCredentials: Bool
    public let retryPolicy: APIRetryPolicy

    public init(
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
    /// External usage:
    /// Called by the app dependency container during startup.
    ///
    /// Environment keys:
    /// - `MVVMEXAMPLE_API_BASE_URL`
    /// - `MVVMEXAMPLE_API_TIMEOUT_SECONDS`
    /// - `MVVMEXAMPLE_ALLOW_DEMO_CREDENTIALS`
    public static func current(
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> APIConfiguration {
        let rawBaseURL = environment["MVVMEXAMPLE_API_BASE_URL"] ?? "https://dummyjson.com"
        let baseURL = URL(string: rawBaseURL) ?? URL(string: "https://dummyjson.com")!

        #if DEBUG
        let defaultAllowsDemoCredentials = true
        #else
        let defaultAllowsDemoCredentials = false
        #endif

        let allowsDemoCredentials = environment["MVVMEXAMPLE_ALLOW_DEMO_CREDENTIALS"]
            .map { $0 == "1" || $0.lowercased() == "true" }
            ?? defaultAllowsDemoCredentials

        let timeout = environment["MVVMEXAMPLE_API_TIMEOUT_SECONDS"]
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
}

/// Explicit demo credential fixture.
///
/// Invariant:
/// These credentials are valid only when `APIConfiguration.allowsDemoCredentials` is true.
public struct DemoCredentials: Equatable, Sendable {
    public let username: String
    public let password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    public static let dummyJSON = DemoCredentials(
        username: "emilys",
        password: "emilyspass"
    )
}


/// Retry contract for network clients.
///
/// Rationale:
/// The default policy is limited to idempotent GET requests so user mutations are not retried implicitly.
public struct APIRetryPolicy: Sendable, Equatable {
    public let maxRetries: Int
    public let retryDelay: TimeInterval
    public let retriesIdempotentGETOnly: Bool

    public init(maxRetries: Int, retryDelay: TimeInterval, retriesIdempotentGETOnly: Bool) {
        self.maxRetries = max(0, maxRetries)
        self.retryDelay = retryDelay
        self.retriesIdempotentGETOnly = retriesIdempotentGETOnly
    }

    public static func idempotentGET(maxRetries: Int, retryDelay: TimeInterval = 0.35) -> APIRetryPolicy {
        APIRetryPolicy(
            maxRetries: maxRetries,
            retryDelay: retryDelay,
            retriesIdempotentGETOnly: true
        )
    }
}
