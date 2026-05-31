import Foundation

public enum AppRuntimeEnvironment: String, Sendable {
    case demo
    case production
}

public struct APIConfiguration: Sendable {
    public let environment: AppRuntimeEnvironment
    public let baseURL: URL
    public let allowsDemoCredentials: Bool

    public init(
        environment: AppRuntimeEnvironment,
        baseURL: URL,
        allowsDemoCredentials: Bool
    ) {
        self.environment = environment
        self.baseURL = baseURL
        self.allowsDemoCredentials = allowsDemoCredentials
    }

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

        return APIConfiguration(
            environment: allowsDemoCredentials ? .demo : .production,
            baseURL: baseURL,
            allowsDemoCredentials: allowsDemoCredentials
        )
    }
}

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
