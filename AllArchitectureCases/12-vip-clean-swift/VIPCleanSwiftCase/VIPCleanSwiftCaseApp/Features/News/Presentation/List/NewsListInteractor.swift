import Foundation
import Observation

/// Owns news-list presentation state, pagination, and user intents.
///
/// Ownership:
/// Created by the news list screen for one navigation flow.
///
/// Responsibilities:
/// - performs initial load, pull-to-refresh, pagination, navigation, and like intents;
/// - keeps pagination errors non-destructive to existing content;
/// - merges shared article interaction state before rendering cards.
///
/// Concurrency:
/// Uses separate task slots for initial load, pagination, and per-article like mutations so cancellation and stale-result handling stay operation-specific.
@MainActor
@Observable
final class NewsListInteractor {
    private(set) var state: NewsListViewState = .idle

    private let pageSize = 30
    private let paginationThreshold = 5
    private let worker: NewsListWorker
    private let presenter: NewsListPresenter
    private weak var router: NewsRouter?
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private var loadNextPageTask: Task<Void, Never>?
    @ObservationIgnored private var likeTasks: [NewsArticle.ID: Task<Void, Never>] = [:]
    private var articles: [NewsArticle] = []
    private var nextSkip = 0
    private var canLoadMore = true
    private var loadGeneration = 0
    private var refreshGeneration = 0
    private var paginationGeneration = 0

    init(
        repository: NewsRepository,
        router: NewsRouter,
        interactionStore: ArticleInteractionStore,
        presenter: NewsListPresenter = NewsListPresenter()
    ) {
        self.worker = NewsListWorker(repository: repository, interactionStore: interactionStore)
        self.router = router
        self.presenter = presenter
    }

    deinit {
        loadTask?.cancel()
        loadNextPageTask?.cancel()
        likeTasks.values.forEach { $0.cancel() }
    }

    /// Loads the first page once when the list enters the screen lifecycle.
    func appeared() {
        loadIfNeeded()
    }

    /// Reconciles visible rows with locally persisted user interactions when returning from detail.
    func becameVisible() {
        synchronizeVisibleContentWithInteractionStore()
    }

    func retryTapped() {
        load()
    }

    /// Refreshes the first page while preserving visible content on failure.
    ///
    /// External usage:
    /// Awaited by SwiftUI `.refreshable` so the system refresh indicator tracks real async work.
    func refreshRequested() async {
        await refresh()
    }

    func articleTapped(id: NewsArticle.ID) {
        openDetail(id: id)
    }

    func likeTapped(id: NewsArticle.ID) {
        toggleLike(articleID: id)
    }

    func commentsTapped(id: NewsArticle.ID) {
        // Comments are visible as counts only in the current product scope.
    }

    /// Requests the next page when a visible row approaches the pagination threshold.
    ///
    /// External usage:
    /// Called from row `onAppear`; this method owns backpressure and duplicate-load prevention.
    func loadNextPageIfNeeded(currentItemID: NewsArticle.ID) {
        guard shouldLoadNextPage(currentItemID: currentItemID) else { return }
        loadNextPage()
    }

    /// Retries a failed pagination request without clearing current content.
    func retryLoadNextPageTapped() {
        guard case .content = state else { return }
        loadNextPage()
    }

    private func loadIfNeeded() {
        guard case .idle = state else { return }
        load()
    }

    private func load() {
        loadTask?.cancel()
        loadNextPageTask?.cancel()
        loadGeneration += 1
        let generation = loadGeneration
        state = .loading

        loadTask = Task { [worker, presenter, pageSize] in
            do {
                let loadedArticles = try await worker.loadFirstPage(pageSize: pageSize)
                try Task.checkCancellation()
                guard generation == loadGeneration else { return }
                articles = worker.mergeInteractionState(into: loadedArticles)
                nextSkip = articles.count
                canLoadMore = loadedArticles.count == pageSize
                state = makeStateForCurrentArticles(presenter: presenter)
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                guard generation == loadGeneration else { return }
                state = .error(presenter.makeError(from: error))
            }
        }
    }

    private func refresh() async {
        guard case .content(let currentContent) = state else {
            load()
            return
        }

        loadNextPageTask?.cancel()
        refreshGeneration += 1
        let generation = refreshGeneration
        state = .refreshing(currentContent)

        do {
            let refreshedArticles = try await worker.refreshFirstPage(pageSize: pageSize)
            try Task.checkCancellation()
            guard generation == refreshGeneration else { return }
            articles = worker.mergeInteractionState(into: refreshedArticles)
            nextSkip = articles.count
            canLoadMore = refreshedArticles.count == pageSize
            state = makeStateForCurrentArticles(presenter: presenter)
        } catch is CancellationError {
            return
        } catch AppAPIError.cancelled {
            return
        } catch {
            guard generation == refreshGeneration else { return }
            var content = currentContent
            content.banner = AppStrings.text("Couldn’t refresh. Showing previous content.")
            state = .content(content)
        }
    }

    private func loadNextPage() {
        guard case .content(let currentContent) = state else { return }
        guard canLoadMore else { return }
        guard loadNextPageTask == nil else { return }

        paginationGeneration += 1
        let generation = paginationGeneration
        let request = NewsPageRequest(limit: pageSize, skip: nextSkip)
        var loadingContent = currentContent
        loadingContent.pagination = presenter.makePaginationLoading()
        loadingContent.banner = nil
        state = .content(loadingContent)

        loadNextPageTask = Task { [worker, presenter] in
            defer { loadNextPageTask = nil }
            do {
                let nextPageArticles = try await worker.loadPage(request)
                try Task.checkCancellation()
                guard generation == paginationGeneration else { return }

                let mergedPage = worker.mergeInteractionState(into: nextPageArticles)
                articles = mergeExistingArticles(articles, with: mergedPage)
                nextSkip += nextPageArticles.count
                canLoadMore = nextPageArticles.count == pageSize
                state = makeStateForCurrentArticles(presenter: presenter)
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                guard generation == paginationGeneration else { return }
                guard case .content(let latestContent) = state else { return }
                var content = latestContent
                content.pagination = presenter.makePaginationError(from: error)
                state = .content(content)
            }
        }
    }

    private func shouldLoadNextPage(currentItemID: NewsArticle.ID) -> Bool {
        guard case .content = state else { return false }
        guard canLoadMore else { return false }
        guard loadNextPageTask == nil else { return false }
        guard let index = articles.firstIndex(where: { $0.id == currentItemID }) else { return false }
        return index >= max(articles.count - paginationThreshold, 0)
    }

    private func synchronizeVisibleContentWithInteractionStore() {
        guard !articles.isEmpty else { return }

        let mergedArticles = worker.mergeInteractionState(into: articles)
        guard mergedArticles != articles else { return }

        articles = mergedArticles
        let updatedCards = presenter.makeContent(from: articles).cards

        switch state {
        case .content(let currentContent):
            state = .content(currentContent.replacingCards(updatedCards))
        case .refreshing(let currentContent):
            state = .refreshing(currentContent.replacingCards(updatedCards))
        default:
            break
        }
    }

    /// Rebuilds content state from the current domain cache.
    ///
    /// UI hot-path note:
    /// Card view states are precomputed here so rows avoid formatting and accessibility string assembly during `body` evaluation.
    private func makeStateForCurrentArticles(
        presenter: NewsListPresenter
    ) -> NewsListViewState {
        guard !articles.isEmpty else {
            return .empty(presenter.makeEmpty())
        }

        var content = presenter.makeContent(from: articles)
        content.pagination = canLoadMore
            ? presenter.makePaginationIdle()
            : presenter.makePaginationEndReached()
        return .content(content)
    }

    private func mergeExistingArticles(
        _ existingArticles: [NewsArticle],
        with incomingArticles: [NewsArticle]
    ) -> [NewsArticle] {
        var mergedArticles = existingArticles
        var existingIDs = Set(existingArticles.map(\.id))

        for article in incomingArticles where !existingIDs.contains(article.id) {
            mergedArticles.append(article)
            existingIDs.insert(article.id)
        }

        return mergedArticles
    }

    private func openDetail(id: Int) {
        guard let card = currentCards.first(where: { $0.id == id }) else { return }
        router?.openDetail(
            NewsDetailRoutePayload(
                id: card.id,
                title: card.title,
                thumbnailURL: card.thumbnailURL
            )
        )
    }

    private func toggleLike(articleID: Int) {
        guard case .content(let content) = state else { return }
        guard let card = content.cards.first(where: { $0.id == articleID }) else { return }
        guard likeTasks[articleID] == nil else { return }

        let targetIsLiked: Bool
        switch card.likeState {
        case .liked:
            targetIsLiked = false
        case .notLiked, .failed:
            targetIsLiked = true
        }

        guard let optimisticArticle = articles
            .first(where: { $0.id == articleID })?
            .replacingLikeState(isLiked: targetIsLiked)
        else { return }

        worker.persistOptimisticInteraction(optimisticArticle)
        articles = articles.map { $0.id == articleID ? optimisticArticle : $0 }

        var optimisticContent = content
        optimisticContent.cards = content.cards.map { item in
            guard item.id == articleID else { return item }
            return presenter.makeCard(from: optimisticArticle)
        }
        state = .content(optimisticContent)

        likeTasks[articleID] = Task { [worker, presenter] in
            defer { likeTasks[articleID] = nil }
            do {
                try await worker.persistLike(articleID: articleID, isLiked: targetIsLiked)
                try Task.checkCancellation()
                worker.acknowledgeLikeSuccess(optimisticArticle, articleID: articleID)
                articles = articles.map { $0.id == articleID ? optimisticArticle : $0 }
                let updatedCard = presenter.makeCard(from: optimisticArticle)

                guard case .content(let latestContent) = state else { return }
                var content = latestContent
                content.cards = latestContent.cards.map { $0.id == articleID ? updatedCard : $0 }
                state = .content(content)
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                guard case .content(let latestContent) = state else { return }
                var content = latestContent
                worker.enqueuePendingLike(articleID: articleID, isLiked: targetIsLiked)
                let localCard = presenter.makeCard(from: optimisticArticle)
                content.cards = latestContent.cards.map { item in
                    item.id == articleID ? localCard : item
                }
                state = .content(content)
            }
        }
    }

    private var currentCards: [NewsCardViewState] {
        switch state {
        case .content(let content), .refreshing(let content):
            return content.cards
        default:
            return []
        }
    }
}

private extension NewsListContentViewState {
    func replacingCards(_ cards: [NewsCardViewState]) -> NewsListContentViewState {
        NewsListContentViewState(
            cards: cards,
            banner: banner,
            pagination: pagination
        )
    }
}

private extension NewsCardViewState {
    func replacingLikeState(_ likeState: LikeButtonState) -> NewsCardViewState {
        NewsCardViewState(
            id: id,
            sourceText: sourceText,
            sourceDisplayText: sourceDisplayText,
            title: title,
            excerpt: excerpt,
            publishedAtText: publishedAtText,
            thumbnailURL: thumbnailURL,
            likesText: likesText,
            commentsText: commentsText,
            likeState: likeState,
            likeIconName: NewsListPresenter.likeIconName(for: likeState),
            accessibilityLabel: accessibilityLabel,
            likeAccessibilityLabel: likeState == .liked ? AppStrings.text("Unlike article") : AppStrings.text("Like article"),
            commentsAccessibilityLabel: commentsAccessibilityLabel
        )
    }
}

private extension NewsArticle {
    func replacingLikeState(isLiked: Bool) -> NewsArticle {
        let adjustedLikesCount: Int
        if isLiked == self.isLiked {
            adjustedLikesCount = likesCount
        } else if isLiked {
            adjustedLikesCount = likesCount + 1
        } else {
            adjustedLikesCount = max(likesCount - 1, 0)
        }

        return NewsArticle(
            id: id,
            title: title,
            excerpt: excerpt,
            source: source,
            category: category,
            rating: rating,
            thumbnailURL: thumbnailURL,
            imageURLs: imageURLs,
            publishedAt: publishedAt,
            likesCount: adjustedLikesCount,
            commentsCount: commentsCount,
            isLiked: isLiked
        )
    }
}


/// Clean Swift Worker for news-list repository and local interaction persistence.
@MainActor
struct NewsListWorker {
    private let repository: NewsRepository
    private let interactionStore: ArticleInteractionStore

    init(repository: NewsRepository, interactionStore: ArticleInteractionStore) {
        self.repository = repository
        self.interactionStore = interactionStore
    }

    func loadFirstPage(pageSize: Int) async throws -> [NewsArticle] {
        try await repository.loadNews(page: NewsPageRequest(limit: pageSize, skip: 0))
    }

    func refreshFirstPage(pageSize: Int) async throws -> [NewsArticle] {
        try await repository.refreshNews(page: NewsPageRequest(limit: pageSize, skip: 0))
    }

    func loadPage(_ request: NewsPageRequest) async throws -> [NewsArticle] {
        try await repository.loadNews(page: request)
    }

    func persistLike(articleID: NewsArticle.ID, isLiked: Bool) async throws {
        _ = try await repository.toggleLike(articleID: articleID, isLiked: isLiked)
    }

    func mergeInteractionState(into articles: [NewsArticle]) -> [NewsArticle] {
        interactionStore.merge(articles)
    }

    func persistOptimisticInteraction(_ article: NewsArticle) {
        interactionStore.update(with: article)
    }

    func acknowledgeLikeSuccess(_ article: NewsArticle, articleID: NewsArticle.ID) {
        interactionStore.update(with: article)
        interactionStore.clearPendingLike(articleID: articleID)
    }

    func enqueuePendingLike(articleID: NewsArticle.ID, isLiked: Bool) {
        interactionStore.enqueuePendingLike(articleID: articleID, isLiked: isLiked)
    }
}
