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
    let pendingMutationSyncService: PendingMutationSyncService
    let modelContainer: ModelContainer
    let demoCredentials: DemoCredentials?

    /// Creates the production-shaped dependency graph for the current process environment.
    ///
    /// Important:
    /// Debug builds may enable demo credentials by default; non-Debug builds must opt in explicitly through configuration.
    static func live() -> AppDependencies {
        #if DEBUG
        if ProcessInfo.processInfo.environment["REDUX_ELM_UDF_CASE_UI_TEST_MODE"] == "1" {
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
        let pendingMutationStore = PendingMutationStore(modelContext: modelContext)
        let profileLocalStore = ProfileLocalStore(modelContext: modelContext)
        let articleInteractionStore = ArticleInteractionStore(
            modelContext: modelContext,
            pendingMutationStore: pendingMutationStore
        )
        let newsRepository = LiveNewsRepository(apiClient: apiClient)
        let profileRemoteRepository = LiveProfileRepository(apiClient: apiClient)
        let profileRepository = OfflineProfileRepository(
            remote: profileRemoteRepository,
            localStore: profileLocalStore,
            pendingMutationStore: pendingMutationStore
        )
        let pendingMutationSyncService = PendingMutationSyncService(
            pendingStore: pendingMutationStore,
            newsRepository: newsRepository,
            profileRepository: profileRemoteRepository
        )

        return AppDependencies(
            configuration: configuration,
            apiClient: apiClient,
            authRepository: LiveAuthRepository(apiClient: apiClient),
            newsRepository: newsRepository,
            profileRepository: profileRepository,
            sessionStore: KeychainSessionStore(),
            articleInteractionStore: articleInteractionStore,
            pendingMutationSyncService: pendingMutationSyncService,
            modelContainer: modelContainer,
            demoCredentials: configuration.allowsDemoCredentials ? .dummyJSON : nil
        )
    }
}
