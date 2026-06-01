import Foundation
import Testing
@testable import AppConfiguration

@Suite("API configuration tests")
struct APIConfigurationTests {
    @Test("Missing base URL uses documented demo default")
    func missingBaseURLUsesDemoDefault() throws {
        let url = try APIConfiguration.makeBaseURL(from: [:])
        #expect(url.absoluteString == "https://dummyjson.com")
    }

    @Test("Valid explicit base URL is accepted")
    func validExplicitBaseURLIsAccepted() throws {
        let url = try APIConfiguration.makeBaseURL(
            from: ["MVVMEXAMPLE_API_BASE_URL": "https://api.example.com"]
        )
        #expect(url.absoluteString == "https://api.example.com")
    }

    @Test("Invalid explicit base URL throws configuration error")
    func invalidExplicitBaseURLThrows() {
        do {
            _ = try APIConfiguration.makeBaseURL(
                from: ["MVVMEXAMPLE_API_BASE_URL": "not a valid production url"]
            )
            Issue.record("Expected invalid base URL to throw")
        } catch APIConfigurationError.invalidBaseURL(let value) {
            #expect(value == "not a valid production url")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test("Environment overrides timeout and demo credential policy")
    func environmentOverridesTimeoutAndDemoCredentialPolicy() {
        let configuration = APIConfiguration.current(
            environment: [
                "MVVMEXAMPLE_API_BASE_URL": "https://api.example.com",
                "MVVMEXAMPLE_API_TIMEOUT_SECONDS": "12.5",
                "MVVMEXAMPLE_ALLOW_DEMO_CREDENTIALS": "false"
            ]
        )

        #expect(configuration.baseURL.absoluteString == "https://api.example.com")
        #expect(configuration.requestTimeout == 12.5)
        #expect(configuration.allowsDemoCredentials == false)
        #expect(configuration.environment == .production)
    }
}

@MainActor
@Suite("Session store tests")
struct SessionStoreTests {
    @Test("In-memory session store saves and clears session")
    func inMemorySessionStoreSavesAndClearsSession() {
        let store = InMemorySessionStore<String>()

        store.save("session-fixture")
        #expect(store.currentSession == "session-fixture")

        store.clear()
        #expect(store.currentSession == nil)
    }
}
