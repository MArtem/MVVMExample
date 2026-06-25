import SwiftData
import Testing
@testable import HexagonalPortsAdaptersCase

@MainActor
@Suite("News detail ViewModel tests")
struct NewsDetailViewModelTests {
    @Test("Appeared loads article detail into content state")
    func appearedLoadsArticleDetailIntoContentState() async {
        let repository = ControllableNewsDetailRepository()
        let viewModel = makeDetailViewModel(repository: repository)

        viewModel.appeared()
        let id = await repository.waitForDetailRequest(at: 0)

        #expect(id == 7)
        guard case .loading(let placeholder) = viewModel.state else {
            Issue.record("Expected loading placeholder")
            return
        }
        #expect(placeholder.title == "Payload title")

        await repository.waitForDetailContinuation(at: 0)
        await repository.completeDetail(at: 0, with: .success(makeDetailArticle(isLiked: false, likesCount: 10)))
        await drainDetailMainActorTasks()

        guard case .content(let content) = viewModel.state else {
            Issue.record("Expected content state")
            return
        }
        #expect(content.id == 7)
        #expect(content.title == "Loaded title")
        #expect(content.isFavorite == false)
        #expect(content.likesText == "Likes 10")
    }

    @Test("Load failure maps to full-screen user-safe error")
    func loadFailureMapsToFullScreenUserSafeError() async {
        let repository = ControllableNewsDetailRepository()
        let viewModel = makeDetailViewModel(repository: repository)

        viewModel.appeared()
        _ = await repository.waitForDetailRequest(at: 0)
        await repository.waitForDetailContinuation(at: 0)
        await repository.completeDetail(at: 0, with: .failure(AppAPIError.offline))
        await drainDetailMainActorTasks()

        guard case .error(let message) = viewModel.state else {
            Issue.record("Expected error state")
            return
        }
        #expect(message.title == "Couldn’t load details")
        #expect(message.message == "You appear to be offline. Check your connection and try again.")
    }

    @Test("Detail load overlays shared interaction state")
    func detailLoadOverlaysSharedInteractionState() async {
        let interactionStore = ArticleInteractionStore()
        interactionStore.setLikeState(articleID: 7, isLiked: true, likesCount: 99)
        let repository = ControllableNewsDetailRepository()
        let viewModel = makeDetailViewModel(repository: repository, interactionStore: interactionStore)

        await loadDetailContent(
            viewModel: viewModel,
            repository: repository,
            article: makeDetailArticle(isLiked: false, likesCount: 10)
        )

        assertDetailContent(viewModel.state, isFavorite: true, likesText: "Likes 99")
    }

    @Test("Cancelled detail load does not publish stale response")
    func cancelledDetailLoadDoesNotPublishStaleResponse() async {
        let repository = ControllableNewsDetailRepository()
        let viewModel = makeDetailViewModel(repository: repository)

        viewModel.appeared()
        _ = await repository.waitForDetailRequest(at: 0)
        await repository.waitForDetailContinuation(at: 0)

        viewModel.retryTapped()
        _ = await repository.waitForDetailRequest(at: 1)
        await repository.waitForDetailContinuation(at: 1)

        await repository.completeDetail(at: 0, with: .success(makeDetailArticle(isLiked: true, likesCount: 99)))
        await drainDetailMainActorTasks()

        guard case .loading = viewModel.state else {
            Issue.record("Expected second loading state after stale first response")
            return
        }

        await repository.completeDetail(at: 1, with: .success(makeDetailArticle(isLiked: false, likesCount: 10)))
        await drainDetailMainActorTasks()

        assertDetailContent(viewModel.state, isFavorite: false, likesText: "Likes 10")
    }

    @Test("Favorite success keeps local optimistic count after stale server acknowledgement")
    func favoriteSuccessKeepsLocalOptimisticCountAfterStaleServerAcknowledgement() async throws {
        let context = try makeInMemoryModelContext()
        let pendingMutationStore = PendingMutationStore(modelContext: context)
        let interactionStore = ArticleInteractionStore(modelContext: context, pendingMutationStore: pendingMutationStore)
        interactionStore.activateUser(id: 42)
        let repository = ControllableNewsDetailRepository()
        let viewModel = makeDetailViewModel(repository: repository, interactionStore: interactionStore)
        await loadDetailContent(viewModel: viewModel, repository: repository, article: makeDetailArticle(isLiked: false, likesCount: 10))

        viewModel.favoriteTapped()
        let call = await repository.waitForToggleRequest(at: 0)

        #expect(call.articleID == 7)
        #expect(call.isLiked == true)
        assertDetailContent(viewModel.state, isFavorite: true, likesText: "Likes 11")

        await repository.waitForToggleContinuation(at: 0)
        await repository.completeToggle(at: 0, with: .success(makeDetailArticle(isLiked: false, likesCount: 10)))
        await drainDetailMainActorTasks()

        assertDetailContent(viewModel.state, isFavorite: true, likesText: "Likes 11")
        #expect(fetchPendingMutations(in: context).isEmpty)
    }

    @Test("Favorite failure keeps optimistic local state and enqueues pending mutation")
    func favoriteFailureKeepsOptimisticLocalStateAndEnqueuesPendingMutation() async throws {
        let context = try makeInMemoryModelContext()
        let pendingMutationStore = PendingMutationStore(modelContext: context)
        let interactionStore = ArticleInteractionStore(modelContext: context, pendingMutationStore: pendingMutationStore)
        interactionStore.activateUser(id: 42)
        let repository = ControllableNewsDetailRepository()
        let viewModel = makeDetailViewModel(repository: repository, interactionStore: interactionStore)
        await loadDetailContent(viewModel: viewModel, repository: repository, article: makeDetailArticle(isLiked: false, likesCount: 10))

        viewModel.favoriteTapped()
        _ = await repository.waitForToggleRequest(at: 0)
        assertDetailContent(viewModel.state, isFavorite: true, likesText: "Likes 11")

        await repository.waitForToggleContinuation(at: 0)
        await repository.completeToggle(at: 0, with: .failure(AppAPIError.timeout))
        await drainDetailMainActorTasks()

        assertDetailContent(viewModel.state, isFavorite: true, likesText: "Likes 11")
        let mutation = try #require(fetchPendingMutations(in: context).first)
        #expect(mutation.key == PersistedPendingMutation.articleLikeKey(userID: 42, articleID: 7))
        #expect(pendingMutationStore.decodeArticleLike(mutation) == PendingArticleLikeMutation(articleID: 7, isLiked: true))
    }

    @Test("Duplicate favorite tap while request is in flight is ignored")
    func duplicateFavoriteTapWhileRequestIsInFlightIsIgnored() async {
        let repository = ControllableNewsDetailRepository()
        let viewModel = makeDetailViewModel(repository: repository)
        await loadDetailContent(viewModel: viewModel, repository: repository, article: makeDetailArticle(isLiked: false, likesCount: 10))

        viewModel.favoriteTapped()
        _ = await repository.waitForToggleRequest(at: 0)
        viewModel.favoriteTapped()
        await drainDetailMainActorTasks()

        #expect(await repository.toggleRequestCount() == 1)
        assertDetailContent(viewModel.state, isFavorite: true, likesText: "Likes 11")
    }
}

private struct DetailToggleCall: Equatable {
    let articleID: NewsArticle.ID
    let isLiked: Bool
}

private actor ControllableNewsDetailRepository: NewsRepository {
    private var detailRequests: [NewsArticle.ID] = []
    private var detailContinuations: [Int: CheckedContinuation<NewsArticle, Error>] = [:]
    private var detailWaiters: [Int: CheckedContinuation<NewsArticle.ID, Never>] = [:]
    private var detailContinuationWaiters: [Int: CheckedContinuation<Void, Never>] = [:]

    private var toggleRequests: [DetailToggleCall] = []
    private var toggleContinuations: [Int: CheckedContinuation<NewsArticle, Error>] = [:]
    private var toggleWaiters: [Int: CheckedContinuation<DetailToggleCall, Never>] = [:]
    private var toggleContinuationWaiters: [Int: CheckedContinuation<Void, Never>] = [:]

    func loadNews(page: NewsPageRequest) async throws -> [NewsArticle] { throw AppAPIError.transport("Unsupported test path") }
    func refreshNews(page: NewsPageRequest) async throws -> [NewsArticle] { throw AppAPIError.transport("Unsupported test path") }

    func loadArticleDetail(id: NewsArticle.ID) async throws -> NewsArticle {
        let index = detailRequests.count
        detailRequests.append(id)
        detailWaiters.removeValue(forKey: index)?.resume(returning: id)
        return try await withCheckedThrowingContinuation { continuation in
            detailContinuations[index] = continuation
            detailContinuationWaiters.removeValue(forKey: index)?.resume()
        }
    }

    func toggleLike(articleID: NewsArticle.ID, isLiked: Bool) async throws -> NewsArticle {
        let index = toggleRequests.count
        let call = DetailToggleCall(articleID: articleID, isLiked: isLiked)
        toggleRequests.append(call)
        toggleWaiters.removeValue(forKey: index)?.resume(returning: call)
        return try await withCheckedThrowingContinuation { continuation in
            toggleContinuations[index] = continuation
            toggleContinuationWaiters.removeValue(forKey: index)?.resume()
        }
    }

    func waitForDetailRequest(at index: Int) async -> NewsArticle.ID {
        if detailRequests.indices.contains(index) { return detailRequests[index] }
        return await withCheckedContinuation { detailWaiters[index] = $0 }
    }

    func waitForDetailContinuation(at index: Int) async {
        if detailContinuations[index] != nil { return }
        await withCheckedContinuation { detailContinuationWaiters[index] = $0 }
    }

    func waitForToggleRequest(at index: Int) async -> DetailToggleCall {
        if toggleRequests.indices.contains(index) { return toggleRequests[index] }
        return await withCheckedContinuation { toggleWaiters[index] = $0 }
    }

    func waitForToggleContinuation(at index: Int) async {
        if toggleContinuations[index] != nil { return }
        await withCheckedContinuation { toggleContinuationWaiters[index] = $0 }
    }

    func completeDetail(at index: Int, with result: Result<NewsArticle, Error>) {
        detailContinuations.removeValue(forKey: index)?.resume(with: result)
    }

    func completeToggle(at index: Int, with result: Result<NewsArticle, Error>) {
        toggleContinuations.removeValue(forKey: index)?.resume(with: result)
    }

    func toggleRequestCount() -> Int {
        toggleRequests.count
    }
}

@MainActor
private func makeDetailViewModel(repository: ControllableNewsDetailRepository) -> NewsDetailViewModel {
    makeDetailViewModel(repository: repository, interactionStore: ArticleInteractionStore())
}

@MainActor
private func makeDetailViewModel(
    repository: ControllableNewsDetailRepository,
    interactionStore: ArticleInteractionStore
) -> NewsDetailViewModel {
    NewsDetailViewModel(
        payload: NewsDetailRoutePayload(id: 7, title: "Payload title", thumbnailURL: nil),
        repository: repository,
        interactionStore: interactionStore
    )
}

@MainActor
private func loadDetailContent(
    viewModel: NewsDetailViewModel,
    repository: ControllableNewsDetailRepository,
    article: NewsArticle
) async {
    viewModel.appeared()
    _ = await repository.waitForDetailRequest(at: 0)
    await repository.waitForDetailContinuation(at: 0)
    await repository.completeDetail(at: 0, with: .success(article))
    await drainDetailMainActorTasks()
}

private func assertDetailContent(
    _ state: NewsDetailViewState,
    isFavorite: Bool,
    likesText: String
) {
    guard case .content(let content) = state else {
        Issue.record("Expected content state")
        return
    }
    #expect(content.isFavorite == isFavorite)
    #expect(content.likesText == likesText)
    #expect(content.favoriteErrorMessage == nil)
}

private func makeDetailArticle(isLiked: Bool, likesCount: Int) -> NewsArticle {
    NewsArticle(
        id: 7,
        title: "Loaded title",
        excerpt: "Loaded excerpt",
        source: "Source",
        category: "general",
        rating: 4.2,
        thumbnailURL: nil,
        imageURLs: [],
        publishedAt: nil,
        likesCount: likesCount,
        commentsCount: 3,
        isLiked: isLiked
    )
}

@MainActor
private func drainDetailMainActorTasks() async {
    for _ in 0..<10 { await Task.yield() }
}
