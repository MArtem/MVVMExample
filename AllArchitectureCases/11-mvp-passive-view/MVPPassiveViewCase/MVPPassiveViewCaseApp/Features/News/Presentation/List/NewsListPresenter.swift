import Foundation
import Observation

/// MVP passive view presenter for the news list screen.
///
/// Ownership:
/// Created by the news list screen for one navigation flow.
///
/// MVP boundary:
/// This presenter owns news-list presentation decisions, pagination, navigation callbacks, repository reads, optimistic likes, and local interaction merge. The SwiftUI list remains passive/render-forwarding and does not own state transitions.
///
/// Concurrency:
/// Uses separate task slots for initial load, pagination, and per-article like mutations so cancellation and stale-result handling stay operation-specific.
@MainActor
@Observable
final class NewsListPresenter {
    typealias State = NewsListViewState

    private(set) var state: State = .idle

    private let pageSize = 30
    private let paginationThreshold = 5
    private let repository: NewsRepository
    private let viewStateBuilder: NewsListViewStateBuilder
    private let interactionStore: ArticleInteractionStore
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
        viewStateBuilder: NewsListViewStateBuilder = NewsListViewStateBuilder()
    ) {
        self.repository = repository
        self.router = router
        self.interactionStore = interactionStore
        self.viewStateBuilder = viewStateBuilder
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

        loadTask = Task { [repository, interactionStore, viewStateBuilder, pageSize] in
            do {
                let loadedArticles = try await repository.loadNews(
                    page: NewsPageRequest(limit: pageSize, skip: 0)
                )
                try Task.checkCancellation()
                guard generation == loadGeneration else { return }
                let mergedArticles = interactionStore.merge(loadedArticles)
                articles = mergedArticles
                nextSkip = mergedArticles.count
                canLoadMore = loadedArticles.count == pageSize
                state = makeStateForCurrentArticles(viewStateBuilder: viewStateBuilder)
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                guard generation == loadGeneration else { return }
                state = .error(viewStateBuilder.makeError(from: error))
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
            let refreshedArticles = try await repository.refreshNews(
                page: NewsPageRequest(limit: pageSize, skip: 0)
            )
            try Task.checkCancellation()
            guard generation == refreshGeneration else { return }
            let mergedArticles = interactionStore.merge(refreshedArticles)
            articles = mergedArticles
            nextSkip = mergedArticles.count
            canLoadMore = refreshedArticles.count == pageSize
            state = makeStateForCurrentArticles(viewStateBuilder: viewStateBuilder)
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
        loadingContent.pagination = viewStateBuilder.makePaginationLoading()
        loadingContent.banner = nil
        state = .content(loadingContent)

        loadNextPageTask = Task { [repository, interactionStore, viewStateBuilder] in
            defer { loadNextPageTask = nil }
            do {
                let nextPageArticles = try await repository.loadNews(page: request)
                try Task.checkCancellation()
                guard generation == paginationGeneration else { return }

                let mergedPage = interactionStore.merge(nextPageArticles)
                let mergedArticles = mergeExistingArticles(articles, with: mergedPage)
                articles = mergedArticles
                nextSkip += nextPageArticles.count
                canLoadMore = nextPageArticles.count == pageSize
                state = makeStateForCurrentArticles(viewStateBuilder: viewStateBuilder)
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                guard generation == paginationGeneration else { return }
                guard case .content(let latestContent) = state else { return }
                var content = latestContent
                content.pagination = viewStateBuilder.makePaginationError(from: error)
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

        let mergedArticles = interactionStore.merge(articles)
        guard mergedArticles != articles else { return }

        articles = mergedArticles
        let updatedCards = viewStateBuilder.makeContent(from: articles).cards

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
        viewStateBuilder: NewsListViewStateBuilder
    ) -> NewsListViewState {
        guard !articles.isEmpty else {
            return .empty(viewStateBuilder.makeEmpty())
        }

        var content = viewStateBuilder.makeContent(from: articles)
        content.pagination = canLoadMore
            ? viewStateBuilder.makePaginationIdle()
            : viewStateBuilder.makePaginationEndReached()
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

        interactionStore.update(with: optimisticArticle)
        articles = articles.map { $0.id == articleID ? optimisticArticle : $0 }

        var optimisticContent = content
        optimisticContent.cards = content.cards.map { item in
            guard item.id == articleID else { return item }
            return viewStateBuilder.makeCard(from: optimisticArticle)
        }
        state = .content(optimisticContent)

        likeTasks[articleID] = Task { [repository, interactionStore, viewStateBuilder] in
            defer { likeTasks[articleID] = nil }
            do {
                _ = try await repository.toggleLike(
                    articleID: articleID,
                    isLiked: targetIsLiked
                )
                try Task.checkCancellation()
                interactionStore.update(with: optimisticArticle)
                interactionStore.clearPendingLike(articleID: articleID)
                articles = articles.map { $0.id == articleID ? optimisticArticle : $0 }
                let updatedCard = viewStateBuilder.makeCard(from: optimisticArticle)

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
                interactionStore.enqueuePendingLike(articleID: articleID, isLiked: targetIsLiked)
                let localCard = viewStateBuilder.makeCard(from: optimisticArticle)
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
            likeIconName: NewsListViewStateBuilder.likeIconName(for: likeState),
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
