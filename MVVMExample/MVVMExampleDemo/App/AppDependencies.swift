import Foundation
import SwiftData

/// Runtime dependency graph for the app target.
///
/// Ownership:
/// Created at app startup and injected into coordinators/screens. It is main-actor isolated because session and navigation-driving stores are UI state dependencies.
///
/// Responsibilities:
/// - selects live/demo-safe infrastructure configuration;
/// - wires repositories to the shared API client;
/// - exposes demo credentials only when configuration permits them.
@MainActor
struct AppDependencies {
    let configuration: APIConfiguration
    let apiClient: APIClient
    let authRepository: AuthRepository
    let newsRepository: NewsRepository
    let profileRepository: ProfileRepository
    let sessionStore: any SessionStore<AuthSession>
    let articleInteractionStore: ArticleInteractionStore
    let modelContainer: ModelContainer
    let demoCredentials: DemoCredentials?

    /// Creates the production-shaped dependency graph for the current process environment.
    ///
    /// Important:
    /// Debug builds may enable demo credentials by default; non-Debug builds must opt in explicitly through configuration.
    static func live() -> AppDependencies {
        #if DEBUG
        if ProcessInfo.processInfo.environment["MVVMEXAMPLE_UI_TEST_MODE"] == "1" {
            return uiTesting()
        }
        #endif

        let configuration = APIConfiguration.current()
        let logger: AppLogger
        #if DEBUG
        logger = RedactingAppLogger { print($0) }
        #else
        logger = NoOpAppLogger()
        #endif

        let apiClient = URLSessionAPIClient(
            configuration: configuration.networkClientConfiguration,
            logger: { logger.log($0) },
            errorMapping: .appAPIError
        )
        let modelContainer: ModelContainer
        do {
            modelContainer = try AppPersistence.makeModelContainer()
        } catch {
            preconditionFailure("Failed to create SwiftData model container: \(error)")
        }
        let modelContext = ModelContext(modelContainer)
        let profileLocalStore = ProfileLocalStore(modelContext: modelContext)
        let articleInteractionStore = ArticleInteractionStore(modelContext: modelContext)

        return AppDependencies(
            configuration: configuration,
            apiClient: apiClient,
            authRepository: LiveAuthRepository(apiClient: apiClient),
            newsRepository: LiveNewsRepository(apiClient: apiClient),
            profileRepository: OfflineProfileRepository(
                remote: LiveProfileRepository(apiClient: apiClient),
                localStore: profileLocalStore
            ),
            sessionStore: KeychainSessionStore(),
            articleInteractionStore: articleInteractionStore,
            modelContainer: modelContainer,
            demoCredentials: configuration.allowsDemoCredentials ? .dummyJSON : nil
        )
    }
}
