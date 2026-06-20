import Foundation
import SwiftData

#if DEBUG
extension AppDependencies {
    /// Creates deterministic in-process dependencies for XCTest UI smoke runs.
    ///
    /// This path is selected only by the explicit `EXPLICIT_INTENT_MVVM_CASE_UI_TEST_MODE=1` launch environment and avoids live network dependencies for accessibility smoke checks.
    static func uiTesting() -> AppDependencies {
        let configuration = APIConfiguration(
            environment: .demo,
            baseURL: URL(string: "https://example.invalid")!,
            requestTimeout: 1,
            allowsDemoCredentials: true,
            retryPolicy: .idempotentGET(maxRetries: 0)
        )
        let logger = NoOpAppLogger()
        let apiClient = URLSessionAPIClient(
            configuration: configuration.networkClientConfiguration,
            logger: { logger.log($0) },
            errorMapping: .appAPIError
        )

        let modelContainer: ModelContainer
        do {
            modelContainer = try AppPersistence.makeModelContainer(inMemory: true)
        } catch {
            preconditionFailure("Failed to create in-memory SwiftData model container: \(error)")
        }
        let modelContext = ModelContext(modelContainer)
        let pendingMutationStore = PendingMutationStore(modelContext: modelContext)
        let articleInteractionStore = ArticleInteractionStore(
            modelContext: modelContext,
            pendingMutationStore: pendingMutationStore
        )
        let newsRepository = UITestNewsRepository()
        let profileRepository = UITestProfileRepository()
        let pendingMutationSyncService = PendingMutationSyncService(
            pendingStore: pendingMutationStore,
            newsRepository: newsRepository,
            profileRepository: profileRepository
        )

        return AppDependencies(
            configuration: configuration,
            apiClient: apiClient,
            authRepository: MockAuthRepository(),
            newsRepository: newsRepository,
            profileRepository: profileRepository,
            sessionStore: InMemorySessionStore<AuthSession>(),
            articleInteractionStore: articleInteractionStore,
            pendingMutationSyncService: pendingMutationSyncService,
            modelContainer: modelContainer,
            demoCredentials: .dummyJSON
        )
    }
}

private struct UITestNewsRepository: NewsRepository {
    private let article = NewsArticle(
        id: 101,
        title: "Accessible MVVM news card",
        excerpt: "A stable UI-test article used to verify card actions remain independently accessible.",
        source: "ExplicitIntentMVVMCase",
        category: "testing",
        rating: 4.9,
        thumbnailURL: nil,
        imageURLs: [],
        publishedAt: Date(timeIntervalSince1970: 1_700_000_000),
        likesCount: 12,
        commentsCount: 3,
        isLiked: false
    )

    func loadNews(page: NewsPageRequest) async throws -> [NewsArticle] {
        page.skip == 0 ? [article] : []
    }

    func refreshNews(page: NewsPageRequest) async throws -> [NewsArticle] {
        try await loadNews(page: page)
    }

    func loadArticleDetail(id: NewsArticle.ID) async throws -> NewsArticle {
        article
    }

    func toggleLike(articleID: NewsArticle.ID, isLiked: Bool) async throws -> NewsArticle {
        NewsArticle(
            id: article.id,
            title: article.title,
            excerpt: article.excerpt,
            source: article.source,
            category: article.category,
            rating: article.rating,
            thumbnailURL: article.thumbnailURL,
            imageURLs: article.imageURLs,
            publishedAt: article.publishedAt,
            likesCount: isLiked ? article.likesCount + 1 : article.likesCount,
            commentsCount: article.commentsCount,
            isLiked: isLiked
        )
    }
}

private struct UITestProfileRepository: ProfileRepository {
    func loadCurrentProfile(session: AuthSession) async throws -> UserProfile {
        UserProfile(
            id: 101,
            username: "uitest-user",
            email: "uitest@example.com",
            firstName: "UI",
            lastName: "Tester",
            phone: "+1 555 0100",
            imageURL: nil,
            companyTitle: "QA Engineer"
        )
    }

    func updateProfile(id: UserProfile.ID, request: UpdateProfileRequest) async throws -> UserProfile {
        UserProfile(
            id: id,
            username: "uitest-user",
            email: request.email,
            firstName: request.firstName,
            lastName: request.lastName,
            phone: "+1 555 0100",
            imageURL: nil,
            companyTitle: "QA Engineer"
        )
    }
}
#endif
