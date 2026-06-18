import Foundation
import Testing
@testable import MVVMExample

@MainActor
@Suite("News list ViewModel tests")
struct NewsListViewModelTests {
    @Test("Appeared loads first page into content state")
    func appearedLoadsFirstPageIntoContentState() async {
        let repository = ControllableNewsRepository()
        let viewModel = makeViewModel(repository: repository)

        viewModel.appeared()
        let request = await repository.waitForLoadRequest(at: 0)

        #expect(request == NewsPageRequest(limit: 30, skip: 0))
        #expect(viewModel.state == .loading)

        await repository.completeLoad(at: 0, with: .success(makeArticles(count: 2)))
        await drainMainActorTasks()

        guard case .content(let content) = viewModel.state else {
            Issue.record("Expected content state")
            return
        }
        #expect(content.cards.map(\.id) == [1, 2])
        #expect(content.pagination.status == .endReached(message: "You’re all caught up"))
    }

    @Test("Refresh failure preserves visible content and shows banner")
    func refreshFailurePreservesVisibleContentAndShowsBanner() async {
        let repository = ControllableNewsRepository()
        let viewModel = makeViewModel(repository: repository)
        await loadInitialContent(viewModel: viewModel, repository: repository, articles: makeArticles(count: 2))

        let refreshTask = Task { await viewModel.refreshRequested() }
        let request = await repository.waitForRefreshRequest(at: 0)

        #expect(request == NewsPageRequest(limit: 30, skip: 0))
        guard case .refreshing(let refreshingContent) = viewModel.state else {
            Issue.record("Expected refreshing state")
            return
        }
        #expect(refreshingContent.cards.map(\.id) == [1, 2])

        await repository.completeRefresh(at: 0, with: .failure(AppAPIError.timeout))
        await refreshTask.value

        guard case .content(let content) = viewModel.state else {
            Issue.record("Expected content state after refresh failure")
            return
        }
        #expect(content.cards.map(\.id) == [1, 2])
        #expect(content.banner == "Couldn’t refresh. Showing previous content.")
    }

    @Test("Like failure marks only target card as failed and keeps content visible")
    func likeFailureMarksOnlyTargetCardAsFailedAndKeepsContentVisible() async {
        let repository = ControllableNewsRepository()
        let viewModel = makeViewModel(repository: repository)
        await loadInitialContent(viewModel: viewModel, repository: repository, articles: makeArticles(count: 2))

        viewModel.likeTapped(id: 1)
        let request = await repository.waitForToggleRequest(at: 0)

        #expect(request.articleID == 1)
        #expect(request.isLiked == true)
        guard case .content(let optimisticContent) = viewModel.state else {
            Issue.record("Expected content state during like update")
            return
        }
        #expect(optimisticContent.cards.first { $0.id == 1 }?.likeState == .updating)
        #expect(optimisticContent.cards.first { $0.id == 2 }?.likeState == .notLiked)

        await repository.completeToggle(at: 0, with: .failure(AppAPIError.offline))
        await drainMainActorTasks()

        guard case .content(let content) = viewModel.state else {
            Issue.record("Expected content state after like failure")
            return
        }
        #expect(content.cards.first { $0.id == 1 }?.likeState == .failed)
        #expect(content.cards.first { $0.id == 2 }?.likeState == .notLiked)
        #expect(content.banner == "Couldn’t update like. Please try again.")
    }

    @Test("Pagination request is backpressured while a page is already loading")
    func paginationRequestIsBackpressuredWhilePageIsAlreadyLoading() async {
        let repository = ControllableNewsRepository()
        let viewModel = makeViewModel(repository: repository)
        await loadInitialContent(viewModel: viewModel, repository: repository, articles: makeArticles(count: 30))

        viewModel.loadNextPageIfNeeded(currentItemID: 28)
        let request = await repository.waitForLoadRequest(at: 1)
        viewModel.loadNextPageIfNeeded(currentItemID: 29)
        await drainMainActorTasks()

        #expect(request == NewsPageRequest(limit: 30, skip: 30))
        #expect(await repository.loadRequestCount() == 2)

        guard case .content(let content) = viewModel.state else {
            Issue.record("Expected content state during pagination")
            return
        }
        #expect(content.pagination.status == .loading)
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
}

@MainActor
private func makeViewModel(repository: ControllableNewsRepository) -> NewsListViewModel {
    NewsListViewModel(
        repository: repository,
        router: NewsRouter(),
        interactionStore: ArticleInteractionStore()
    )
}

@MainActor
private func loadInitialContent(
    viewModel: NewsListViewModel,
    repository: ControllableNewsRepository,
    articles: [NewsArticle]
) async {
    viewModel.appeared()
    _ = await repository.waitForLoadRequest(at: 0)
    await repository.completeLoad(at: 0, with: .success(articles))
    await drainMainActorTasks()
}

private func makeArticles(count: Int) -> [NewsArticle] {
    (1...count).map { id in
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
            likesCount: id,
            commentsCount: id * 2,
            isLiked: false
        )
    }
}

@MainActor
private func drainMainActorTasks() async {
    for _ in 0..<10 {
        await Task.yield()
    }
}
