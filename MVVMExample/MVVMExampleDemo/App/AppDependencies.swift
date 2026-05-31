import Foundation

@MainActor
struct AppDependencies {
    let configuration: APIConfiguration
    let apiClient: APIClient
    let authRepository: AuthRepository
    let newsRepository: NewsRepository
    let profileRepository: ProfileRepository
    let sessionStore: InMemorySessionStore<AuthSession>
    let articleInteractionStore: ArticleInteractionStore
    let demoCredentials: DemoCredentials?

    static func live() -> AppDependencies {
        let configuration = APIConfiguration.current()
        let logger: AppLogger
        #if DEBUG
        logger = RedactingAppLogger { print($0) }
        #else
        logger = NoOpAppLogger()
        #endif

        let apiClient = URLSessionAPIClient(
            configuration: configuration,
            logger: logger
        )

        return AppDependencies(
            configuration: configuration,
            apiClient: apiClient,
            authRepository: LiveAuthRepository(apiClient: apiClient),
            newsRepository: LiveNewsRepository(apiClient: apiClient),
            profileRepository: LiveProfileRepository(apiClient: apiClient),
            sessionStore: InMemorySessionStore<AuthSession>(),
            articleInteractionStore: ArticleInteractionStore(),
            demoCredentials: configuration.allowsDemoCredentials ? .dummyJSON : nil
        )
    }
}
