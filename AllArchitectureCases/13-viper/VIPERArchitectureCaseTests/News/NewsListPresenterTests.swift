import Foundation
import SwiftData
import Testing
@testable import VIPERArchitectureCase

@MainActor
@Suite("News list Presenter tests")
struct NewsListPresenterTests {
    @Test("Appeared loads first page into content state")
    func appearedLoadsFirstPageIntoContentState() async {
        let repository = ControllableNewsRepository()
        let presenter = makePresenter(repository: repository)

        presenter.appeared()
        let request = await repository.waitForLoadRequest(at: 0)

        #expect(request == NewsPageRequest(limit: 30, skip: 0))
        #expect(presenter.state == .loading)

        await repository.completeLoad(at: 0, with: .success(makeArticles(count: 2)))
        await drainMainActorTasks()

        guard case .content(let content) = presenter.state else {
            Issue.record("Expected content state")
            return
        }
        #expect(content.cards.map(\.id) == [1, 2])
        #expect(content.pagination.status == .endReached(message: "You’re all caught up"))
    }

    @Test("Refresh failure preserves visible content and shows banner")
    func refreshFailurePreservesVisibleContentAndShowsBanner() async {
        let repository = ControllableNewsRepository()
        let presenter = makePresenter(repository: repository)
        await loadInitialContent(presenter: presenter, repository: repository, articles: makeArticles(count: 2))

        let refreshTask = Task { await presenter.refreshRequested() }
        let request = await repository.waitForRefreshRequest(at: 0)

        #expect(request == NewsPageRequest(limit: 30, skip: 0))
        guard case .refreshing(let refreshingContent) = presenter.state else {
            Issue.record("Expected refreshing state")
            return
        }
        #expect(refreshingContent.cards.map(\.id) == [1, 2])

        await repository.completeRefresh(at: 0, with: .failure(AppAPIError.timeout))
        await refreshTask.value

        guard case .content(let content) = presenter.state else {
            Issue.record("Expected content state after refresh failure")
            return
        }
        #expect(content.cards.map(\.id) == [1, 2])
        #expect(content.banner == "Couldn’t refresh. Showing previous content.")
    }

    @Test("Refresh applies persisted optimistic interaction state")
    func refreshAppliesPersistedOptimisticInteractionState() async {
        let interactionStore = ArticleInteractionStore()
        let repository = ControllableNewsRepository()
        let presenter = makePresenter(repository: repository, interactionStore: interactionStore)
        await loadInitialContent(presenter: presenter, repository: repository, articles: makeArticles(count: 2))
        interactionStore.setLikeState(articleID: 1, isLiked: true, likesCount: 99)

        let refreshTask = Task { await presenter.refreshRequested() }
        _ = await repository.waitForRefreshRequest(at: 0)
        await repository.completeRefresh(at: 0, with: .success(makeArticles(count: 2)))
        await refreshTask.value

        assertCard(presenter.state, id: 1, likeState: .liked, likesText: "99")
        assertCard(presenter.state, id: 2, likeState: .notLiked, likesText: "2")
    }

    @Test("Like success uses local optimistic count instead of stale server count")
    func likeSuccessUsesLocalOptimisticCountInsteadOfStaleServerCount() async {
        let repository = ControllableNewsRepository()
        let presenter = makePresenter(repository: repository)
        await loadInitialContent(presenter: presenter, repository: repository, articles: makeArticles(count: 2))

        presenter.likeTapped(id: 1)
        let request = await repository.waitForToggleRequest(at: 0)

        #expect(request == ToggleLikeCall(articleID: 1, isLiked: true))
        assertCard(presenter.state, id: 1, likeState: .liked, likesText: "2")

        await repository.completeToggle(at: 0, with: .success(makeArticle(id: 1, isLiked: false, likesCount: 1)))
        await drainMainActorTasks()

        assertCard(presenter.state, id: 1, likeState: .liked, likesText: "2")
        assertCard(presenter.state, id: 2, likeState: .notLiked, likesText: "2")
    }

    @Test("Unlike success uses local optimistic count instead of stale server count")
    func unlikeSuccessUsesLocalOptimisticCountInsteadOfStaleServerCount() async {
        let repository = ControllableNewsRepository()
        let presenter = makePresenter(repository: repository)
        await loadInitialContent(presenter: presenter, repository: repository, articles: [
            makeArticle(id: 1, isLiked: true, likesCount: 5),
            makeArticle(id: 2, isLiked: false, likesCount: 2)
        ])

        presenter.likeTapped(id: 1)
        let request = await repository.waitForToggleRequest(at: 0)

        #expect(request == ToggleLikeCall(articleID: 1, isLiked: false))
        assertCard(presenter.state, id: 1, likeState: .notLiked, likesText: "4")

        await repository.completeToggle(at: 0, with: .success(makeArticle(id: 1, isLiked: true, likesCount: 5)))
        await drainMainActorTasks()

        assertCard(presenter.state, id: 1, likeState: .notLiked, likesText: "4")
    }

    @Test("Like failure keeps optimistic state and enqueues pending mutation")
    func likeFailureKeepsOptimisticStateAndEnqueuesPendingMutation() async throws {
        let context = try makeInMemoryModelContext()
        let pendingMutationStore = PendingMutationStore(modelContext: context)
        let interactionStore = ArticleInteractionStore(modelContext: context, pendingMutationStore: pendingMutationStore)
        interactionStore.activateUser(id: 42)
        let repository = ControllableNewsRepository()
        let presenter = makePresenter(repository: repository, interactionStore: interactionStore)
        await loadInitialContent(presenter: presenter, repository: repository, articles: makeArticles(count: 2))

        presenter.likeTapped(id: 1)
        let request = await repository.waitForToggleRequest(at: 0)

        #expect(request == ToggleLikeCall(articleID: 1, isLiked: true))
        assertCard(presenter.state, id: 1, likeState: .liked, likesText: "2")
        assertCard(presenter.state, id: 2, likeState: .notLiked, likesText: "2")

        await repository.completeToggle(at: 0, with: .failure(AppAPIError.offline))
        await drainMainActorTasks()

        assertCard(presenter.state, id: 1, likeState: .liked, likesText: "2")
        assertCard(presenter.state, id: 2, likeState: .notLiked, likesText: "2")
        let mutation = try #require(fetchPendingMutations(in: context).first)
        #expect(mutation.key == PersistedPendingMutation.articleLikeKey(userID: 42, articleID: 1))
        #expect(pendingMutationStore.decodeArticleLike(mutation) == PendingArticleLikeMutation(articleID: 1, isLiked: true))
    }

    @Test("Duplicate like tap while request is in flight is ignored")
    func duplicateLikeTapWhileRequestIsInFlightIsIgnored() async {
        let repository = ControllableNewsRepository()
        let presenter = makePresenter(repository: repository)
        await loadInitialContent(presenter: presenter, repository: repository, articles: makeArticles(count: 2))

        presenter.likeTapped(id: 1)
        _ = await repository.waitForToggleRequest(at: 0)
        presenter.likeTapped(id: 1)
        await drainMainActorTasks()

        #expect(await repository.toggleRequestCount() == 1)
        assertCard(presenter.state, id: 1, likeState: .liked, likesText: "2")
    }

    @Test("becameVisible updates list card after shared interaction store change")
    func becameVisibleUpdatesListCardAfterSharedInteractionStoreChange() async {
        let interactionStore = ArticleInteractionStore()
        let repository = ControllableNewsRepository()
        let presenter = makePresenter(repository: repository, interactionStore: interactionStore)
        await loadInitialContent(presenter: presenter, repository: repository, articles: makeArticles(count: 2))

        interactionStore.setLikeState(articleID: 1, isLiked: true, likesCount: 99)
        presenter.becameVisible()

        assertCard(presenter.state, id: 1, likeState: .liked, likesText: "99")
        assertCard(presenter.state, id: 2, likeState: .notLiked, likesText: "2")
    }

    @Test("Pagination request is backpressured while a page is already loading")
    func paginationRequestIsBackpressuredWhilePageIsAlreadyLoading() async {
        let repository = ControllableNewsRepository()
        let presenter = makePresenter(repository: repository)
        await loadInitialContent(presenter: presenter, repository: repository, articles: makeArticles(count: 30))

        presenter.loadNextPageIfNeeded(currentItemID: 28)
        let request = await repository.waitForLoadRequest(at: 1)
        presenter.loadNextPageIfNeeded(currentItemID: 29)
        await drainMainActorTasks()

        #expect(request == NewsPageRequest(limit: 30, skip: 30))
        #expect(await repository.loadRequestCount() == 2)

        guard case .content(let content) = presenter.state else {
            Issue.record("Expected content state during pagination")
            return
        }
        #expect(content.pagination.status == .loading)
    }

    @Test("Pagination page merge applies persisted interaction state")
    func paginationPageMergeAppliesPersistedInteractionState() async {
        let interactionStore = ArticleInteractionStore()
        let repository = ControllableNewsRepository()
        let presenter = makePresenter(repository: repository, interactionStore: interactionStore)
        await loadInitialContent(presenter: presenter, repository: repository, articles: makeArticles(count: 30))
        interactionStore.setLikeState(articleID: 31, isLiked: true, likesCount: 99)

        presenter.loadNextPageIfNeeded(currentItemID: 28)
        let request = await repository.waitForLoadRequest(at: 1)

        #expect(request == NewsPageRequest(limit: 30, skip: 30))

        await repository.completeLoad(at: 1, with: .success([
            makeArticle(id: 31, isLiked: false, likesCount: 31),
            makeArticle(id: 32, isLiked: false, likesCount: 32)
        ]))
        await drainMainActorTasks()

        assertCard(presenter.state, id: 31, likeState: .liked, likesText: "99")
        assertCard(presenter.state, id: 32, likeState: .notLiked, likesText: "32")
    }

    @Test("Pagination failure can be retried without advancing skip")
    func paginationFailureCanBeRetriedWithoutAdvancingSkip() async {
        let repository = ControllableNewsRepository()
        let presenter = makePresenter(repository: repository)
        await loadInitialContent(presenter: presenter, repository: repository, articles: makeArticles(count: 30))

        presenter.loadNextPageIfNeeded(currentItemID: 28)
        let failedRequest = await repository.waitForLoadRequest(at: 1)
        await repository.completeLoad(at: 1, with: .failure(AppAPIError.timeout))
        await drainMainActorTasks()

        #expect(failedRequest == NewsPageRequest(limit: 30, skip: 30))

        guard case .content(let failedContent) = presenter.state else {
            Issue.record("Expected content state after pagination failure")
            return
        }
        #expect(failedContent.pagination.status == .error(
            message: "The request took too long. Please try again.",
            retryTitle: "Retry loading more"
        ))

        presenter.retryLoadNextPageTapped()
        let retryRequest = await repository.waitForLoadRequest(at: 2)

        #expect(retryRequest == NewsPageRequest(limit: 30, skip: 30))

        await repository.completeLoad(at: 2, with: .success([makeArticle(id: 31, isLiked: false, likesCount: 31)]))
        await drainMainActorTasks()

        assertCard(presenter.state, id: 31, likeState: .notLiked, likesText: "31")
    }
}

private struct ToggleLikeCall: Equatable {
    let articleID: NewsArticle.ID
    let isLiked: Bool
}

private actor ControllableNewsRepository: NewsRepository {
    private var loadRequests: [NewsPageRequest] = []
    private var loadContinuations: [Int: CheckedContinuation<[NewsArticle], Error>] = [:]
    private var pendingLoadResults: [Int: Result<[NewsArticle], Error>] = [:]
    private var loadWaiters: [Int: CheckedContinuation<NewsPageRequest, Never>] = [:]

    private var refreshRequests: [NewsPageRequest] = []
    private var refreshContinuations: [Int: CheckedContinuation<[NewsArticle], Error>] = [:]
    private var pendingRefreshResults: [Int: Result<[NewsArticle], Error>] = [:]
    private var refreshWaiters: [Int: CheckedContinuation<NewsPageRequest, Never>] = [:]

    private var toggleRequests: [ToggleLikeCall] = []
    private var toggleContinuations: [Int: CheckedContinuation<NewsArticle, Error>] = [:]
    private var pendingToggleResults: [Int: Result<NewsArticle, Error>] = [:]
    private var toggleWaiters: [Int: CheckedContinuation<ToggleLikeCall, Never>] = [:]

    func loadNews(page: NewsPageRequest) async throws -> [NewsArticle] {
        let index = loadRequests.count
        loadRequests.append(page)
        loadWaiters.removeValue(forKey: index)?.resume(returning: page)
        return try await withCheckedThrowingContinuation { continuation in
            if let pendingResult = pendingLoadResults.removeValue(forKey: index) {
                continuation.resume(with: pendingResult)
            } else {
                loadContinuations[index] = continuation
            }
        }
    }

    func refreshNews(page: NewsPageRequest) async throws -> [NewsArticle] {
        let index = refreshRequests.count
        refreshRequests.append(page)
        refreshWaiters.removeValue(forKey: index)?.resume(returning: page)
        return try await withCheckedThrowingContinuation { continuation in
            if let pendingResult = pendingRefreshResults.removeValue(forKey: index) {
                continuation.resume(with: pendingResult)
            } else {
                refreshContinuations[index] = continuation
            }
        }
    }

    func loadArticleDetail(id: NewsArticle.ID) async throws -> NewsArticle {
        throw AppAPIError.transport("Unsupported test path")
    }

    func toggleLike(articleID: NewsArticle.ID, isLiked: Bool) async throws -> NewsArticle {
        let index = toggleRequests.count
        let call = ToggleLikeCall(articleID: articleID, isLiked: isLiked)
        toggleRequests.append(call)
        toggleWaiters.removeValue(forKey: index)?.resume(returning: call)
        return try await withCheckedThrowingContinuation { continuation in
            if let pendingResult = pendingToggleResults.removeValue(forKey: index) {
                continuation.resume(with: pendingResult)
            } else {
                toggleContinuations[index] = continuation
            }
        }
    }

    func waitForLoadRequest(at index: Int) async -> NewsPageRequest {
        if loadRequests.indices.contains(index) { return loadRequests[index] }
        return await withCheckedContinuation { continuation in
            loadWaiters[index] = continuation
        }
    }

    func waitForRefreshRequest(at index: Int) async -> NewsPageRequest {
        if refreshRequests.indices.contains(index) { return refreshRequests[index] }
        return await withCheckedContinuation { continuation in
            refreshWaiters[index] = continuation
        }
    }

    func waitForToggleRequest(at index: Int) async -> ToggleLikeCall {
        if toggleRequests.indices.contains(index) { return toggleRequests[index] }
        return await withCheckedContinuation { continuation in
            toggleWaiters[index] = continuation
        }
    }

    func completeLoad(at index: Int, with result: Result<[NewsArticle], Error>) {
        guard let continuation = loadContinuations.removeValue(forKey: index) else {
            pendingLoadResults[index] = result
            return
        }
        continuation.resume(with: result)
    }

    func completeRefresh(at index: Int, with result: Result<[NewsArticle], Error>) {
        guard let continuation = refreshContinuations.removeValue(forKey: index) else {
            pendingRefreshResults[index] = result
            return
        }
        continuation.resume(with: result)
    }

    func completeToggle(at index: Int, with result: Result<NewsArticle, Error>) {
        guard let continuation = toggleContinuations.removeValue(forKey: index) else {
            pendingToggleResults[index] = result
            return
        }
        continuation.resume(with: result)
    }

    func loadRequestCount() -> Int {
        loadRequests.count
    }

    func toggleRequestCount() -> Int {
        toggleRequests.count
    }
}

@MainActor
private func makePresenter(repository: ControllableNewsRepository) -> NewsListPresenter {
    makePresenter(repository: repository, interactionStore: ArticleInteractionStore())
}

@MainActor
private func makePresenter(
    repository: ControllableNewsRepository,
    interactionStore: ArticleInteractionStore
) -> NewsListPresenter {
    NewsListPresenter(
        interactor: NewsListInteractor(repository: repository, interactionStore: interactionStore),
        router: NewsRouter()
    )
}

@MainActor
private func loadInitialContent(
    presenter: NewsListPresenter,
    repository: ControllableNewsRepository,
    articles: [NewsArticle]
) async {
    presenter.appeared()
    _ = await repository.waitForLoadRequest(at: 0)
    await repository.completeLoad(at: 0, with: .success(articles))
    await drainMainActorTasks()
}

private func assertCard(
    _ state: NewsListViewState,
    id: NewsArticle.ID,
    likeState: LikeButtonState,
    likesText: String
) {
    guard case .content(let content) = state else {
        Issue.record("Expected content state")
        return
    }
    guard let card = content.cards.first(where: { $0.id == id }) else {
        Issue.record("Expected card \(id)")
        return
    }
    #expect(card.likeState == likeState)
    #expect(card.likesText == likesText)
}

private func makeArticles(count: Int) -> [NewsArticle] {
    (1...count).map { id in makeArticle(id: id, isLiked: false, likesCount: id) }
}

private func makeArticle(id: Int, isLiked: Bool, likesCount: Int) -> NewsArticle {
    NewsArticle(
        id: id,
        title: "Article \(id)",
        excerpt: "Excerpt \(id)",
        source: "Source",
        category: "General",
        rating: 4.5,
        thumbnailURL: nil,
        imageURLs: [],
        publishedAt: nil,
        likesCount: likesCount,
        commentsCount: id * 2,
        isLiked: isLiked
    )
}

@MainActor
private func drainMainActorTasks() async {
    for _ in 0..<10 {
        await Task.yield()
    }
}
