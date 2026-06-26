import Foundation
import SwiftData
import Testing
@testable import MVCMigrationCase

@MainActor
@Suite("App root coordinator tests")
struct AppRootCoordinatorTests {
    @Test("Login success stores session activates local user and replays pending sync")
    func loginSuccessStoresSessionActivatesLocalUserAndReplaysPendingSync() async throws {
        let container = try makeInMemoryModelContainer()
        let context = ModelContext(container)
        let session = makeCoordinatorSession(userID: 43)
        let sessionStore = InMemorySessionStore<AuthSession>()
        let dependencies = makeCoordinatorDependencies(
            context: context,
            modelContainer: container,
            sessionStore: sessionStore
        )
        dependencies.articleInteractionStore.activateUser(id: 43)
        dependencies.articleInteractionStore.setLikeState(articleID: 8, isLiked: true, likesCount: 12)
        dependencies.articleInteractionStore.enqueuePendingLike(articleID: 8, isLiked: true)
        dependencies.articleInteractionStore.clearActiveUser()
        let coordinator = AppRootCoordinator(dependencies: dependencies)

        coordinator.handleLoginSuccess(session)
        await drainCoordinatorMainActorTasks()

        let mergedArticle = dependencies.articleInteractionStore.merge(makeCoordinatorArticle(id: 8, isLiked: false, likesCount: 11))

        #expect(sessionStore.currentSession == session)
        #expect(coordinator.scene == .main)
        #expect(coordinator.mainCoordinator != nil)
        #expect(mergedArticle.isLiked == true)
        #expect(mergedArticle.likesCount == 12)
        #expect(fetchPendingMutations(in: context).isEmpty)
    }

    @Test("Startup restores saved session and logout clears active local state")
    func startupRestoresSavedSessionAndLogoutClearsActiveLocalState() throws {
        let container = try makeInMemoryModelContainer()
        let context = ModelContext(container)
        let restoredSession = makeCoordinatorSession(userID: 42)
        let restoredDependencies = makeCoordinatorDependencies(
            context: context,
            modelContainer: container,
            sessionStore: InMemorySessionStore(initialSession: restoredSession)
        )
        restoredDependencies.articleInteractionStore.activateUser(id: 42)
        restoredDependencies.articleInteractionStore.setLikeState(articleID: 7, isLiked: true, likesCount: 11)
        restoredDependencies.articleInteractionStore.clearActiveUser()

        let restoredCoordinator = AppRootCoordinator(dependencies: restoredDependencies)
        let restoredMerged = restoredDependencies.articleInteractionStore.merge(makeCoordinatorArticle(id: 7, isLiked: false, likesCount: 10))

        #expect(restoredCoordinator.scene == .main)
        #expect(restoredCoordinator.mainCoordinator != nil)
        #expect(restoredMerged.isLiked == true)
        #expect(restoredMerged.likesCount == 11)

        let sessionStore = InMemorySessionStore<AuthSession>()
        let logoutDependencies = makeCoordinatorDependencies(
            context: context,
            modelContainer: container,
            sessionStore: sessionStore
        )
        let logoutCoordinator = AppRootCoordinator(dependencies: logoutDependencies)
        logoutCoordinator.handleLoginSuccess(restoredSession)
        logoutDependencies.articleInteractionStore.setLikeState(articleID: 7, isLiked: true, likesCount: 11)

        logoutCoordinator.logout()
        let mergedAfterLogout = logoutDependencies.articleInteractionStore.merge(makeCoordinatorArticle(id: 7, isLiked: false, likesCount: 10))

        #expect(sessionStore.currentSession == nil)
        #expect(logoutCoordinator.scene == .login)
        #expect(logoutCoordinator.mainCoordinator == nil)
        #expect(mergedAfterLogout.isLiked == false)
        #expect(mergedAfterLogout.likesCount == 10)
    }
}

@MainActor
func makeCoordinatorDependencies(
    context: ModelContext,
    modelContainer: ModelContainer,
    sessionStore: InMemorySessionStore<AuthSession>
) -> AppDependencies {
    let pendingStore = PendingMutationStore(modelContext: context)
    let articleStore = ArticleInteractionStore(modelContext: context, pendingMutationStore: pendingStore)
    let newsRepository = CoordinatorNewsRepository()
    let profileRepository = CoordinatorProfileRepository()
    return AppDependencies(
        configuration: APIConfiguration(
            environment: .demo,
            baseURL: URL(string: "https://example.invalid")!,
            requestTimeout: 1,
            allowsDemoCredentials: true,
            retryPolicy: .idempotentGET(maxRetries: 0)
        ),
        apiClient: CoordinatorNetworkClient(),
        authRepository: CoordinatorAuthRepository(),
        newsRepository: newsRepository,
        profileRepository: profileRepository,
        sessionStore: sessionStore,
        articleInteractionStore: articleStore,
        pendingMutationSyncService: PendingMutationSyncService(
            pendingStore: pendingStore,
            newsRepository: newsRepository,
            profileRepository: profileRepository
        ),
        modelContainer: modelContainer,
        demoCredentials: .dummyJSON
    )
}

private struct CoordinatorNetworkClient: APIClient {
    func send<Response: Decodable>(_ request: NetworkRequest) async throws -> Response {
        throw AppAPIError.transport("Unsupported test path")
    }
}

private struct CoordinatorAuthRepository: AuthRepository {
    func login(username: String, password: String) async throws -> AuthSession {
        makeCoordinatorSession(userID: 42)
    }
}

private struct CoordinatorNewsRepository: NewsRepository {
    func loadNews(page: NewsPageRequest) async throws -> [NewsArticle] { [] }
    func refreshNews(page: NewsPageRequest) async throws -> [NewsArticle] { [] }
    func loadArticleDetail(id: NewsArticle.ID) async throws -> NewsArticle { makeCoordinatorArticle(id: id, isLiked: false, likesCount: 0) }
    func toggleLike(articleID: NewsArticle.ID, isLiked: Bool) async throws -> NewsArticle { makeCoordinatorArticle(id: articleID, isLiked: isLiked, likesCount: isLiked ? 1 : 0) }
}

private struct CoordinatorProfileRepository: ProfileRepository {
    func loadCurrentProfile(session: AuthSession) async throws -> UserProfile {
        UserProfile(
            id: session.user.id,
            username: session.user.username,
            email: session.user.email,
            firstName: session.user.firstName,
            lastName: session.user.lastName,
            phone: nil,
            imageURL: nil,
            companyTitle: nil
        )
    }

    func updateProfile(id: UserProfile.ID, request: UpdateProfileRequest) async throws -> UserProfile {
        UserProfile(
            id: id,
            username: "fixture-user",
            email: request.email,
            firstName: request.firstName,
            lastName: request.lastName,
            phone: nil,
            imageURL: nil,
            companyTitle: nil
        )
    }
}

private func makeCoordinatorSession(userID: Int) -> AuthSession {
    AuthSession(
        accessToken: "coordinator-access-token-not-a-secret",
        refreshToken: "coordinator-refresh-token-not-a-secret",
        user: AppUser(
            id: userID,
            username: "user\(userID)",
            email: "user\(userID)@example.com",
            firstName: "User",
            lastName: "\(userID)",
            imageURL: nil
        )
    )
}

private func makeCoordinatorArticle(id: Int, isLiked: Bool, likesCount: Int) -> NewsArticle {
    NewsArticle(
        id: id,
        title: "Article \(id)",
        excerpt: "Excerpt",
        source: "Source",
        category: "General",
        rating: 4.5,
        thumbnailURL: nil,
        imageURLs: [],
        publishedAt: nil,
        likesCount: likesCount,
        commentsCount: 0,
        isLiked: isLiked
    )
}

@MainActor
private func drainCoordinatorMainActorTasks() async {
    for _ in 0..<10 { await Task.yield() }
}
