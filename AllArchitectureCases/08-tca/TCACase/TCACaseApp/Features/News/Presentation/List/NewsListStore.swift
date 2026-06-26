import Foundation
import Observation

/// TCA semantic note:
/// The public `state` remains the rendered view state for SwiftUI compatibility, while feature-local `FeatureState` keeps non-rendered domain/cache/form state explicit so effects and reducers do not hide state-machine data in anonymous fields.
///
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
final class NewsListStore {
    struct FeatureState: Equatable {
        var articles: [NewsArticle] = []
        var nextSkip: Int = 0
        var canLoadMore: Bool = true
    }

    typealias State = NewsListViewState

    private enum Action {
        case appeared
        case becameVisible
        case retryTapped
        case refreshRequested
        case articleTapped(NewsArticle.ID)
        case likeTapped(NewsArticle.ID)
        case commentsTapped(NewsArticle.ID)
        case loadNextPageIfNeeded(NewsArticle.ID)
        case retryLoadNextPageTapped
    }

    private enum Effect {
        case loadFirstPage
        case refreshFirstPage
        case loadNextPage
        case toggleLike(NewsArticle.ID)
    }

    private enum StateMutation {
        case setState(NewsListViewState)
        case setArticles([NewsArticle])
        case setPagination(nextSkip: Int, canLoadMore: Bool)
        case clearLoadNextPageTask
    }

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
        handle(.appeared)
    }

    /// Reconciles visible rows with locally persisted user interactions when returning from detail.
    func becameVisible() {
        handle(.becameVisible)
    }

    func retryTapped() {
        handle(.retryTapped)
    }

    /// Refreshes the first page while preserving visible content on failure.
    ///
    /// External usage:
    /// Awaited by SwiftUI `.refreshable` so the system refresh indicator tracks real async work.
    func refreshRequested() async {
        await handleAsync(.refreshRequested)
    }

    func articleTapped(id: NewsArticle.ID) {
        handle(.articleTapped(id))
    }

    func likeTapped(id: NewsArticle.ID) {
        handle(.likeTapped(id))
    }

    func commentsTapped(id: NewsArticle.ID) {
        handle(.commentsTapped(id))
    }

    /// Requests the next page when a visible row approaches the pagination threshold.
    ///
    /// External usage:
    /// Called from row `onAppear`; this method owns backpressure and duplicate-load prevention.
    func loadNextPageIfNeeded(currentItemID: NewsArticle.ID) {
        handle(.loadNextPageIfNeeded(currentItemID))
    }

    /// Retries a failed pagination request without clearing current content.
    func retryLoadNextPageTapped() {
        handle(.retryLoadNextPageTapped)
    }

    private func handle(_ action: Action) {
        switch action {
        case .appeared:
            loadIfNeeded()
        case .becameVisible:
            synchronizeVisibleContentWithInteractionStore()
        case .retryTapped:
            run(.loadFirstPage)
        case .refreshRequested:
            break
        case .articleTapped(let id):
            openDetail(id: id)
        case .likeTapped(let id):
            run(.toggleLike(id))
        case .commentsTapped:
            // Comments are visible as counts only in the current product scope.
            break
        case .loadNextPageIfNeeded(let id):
            guard shouldLoadNextPage(currentItemID: id) else { return }
            run(.loadNextPage)
        case .retryLoadNextPageTapped:
            guard case .content = state else { return }
            run(.loadNextPage)
        }
    }

    private func handleAsync(_ action: Action) async {
        switch action {
        case .refreshRequested:
            await runAsync(.refreshFirstPage)
        default:
            handle(action)
        }
    }

    private func run(_ effect: Effect) {
        switch effect {
        case .loadFirstPage:
            load()
        case .refreshFirstPage:
            break
        case .loadNextPage:
            loadNextPage()
        case .toggleLike(let id):
            toggleLike(articleID: id)
        }
    }

    private func runAsync(_ effect: Effect) async {
        switch effect {
        case .refreshFirstPage:
            await refresh()
        default:
            run(effect)
        }
    }

    private func reduce(_ mutation: StateMutation) {
        switch mutation {
        case .setState(let state):
            self.state = state
        case .setArticles(let articles):
            self.articles = articles
        case .setPagination(let nextSkip, let canLoadMore):
            self.nextSkip = nextSkip
            self.canLoadMore = canLoadMore
        case .clearLoadNextPageTask:
            self.loadNextPageTask = nil
        }
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
        reduce(.setState(.loading))

        loadTask = Task { [repository, interactionStore, viewStateBuilder, pageSize] in
            do {
                let loadedArticles = try await repository.loadNews(
                    page: NewsPageRequest(limit: pageSize, skip: 0)
                )
                try Task.checkCancellation()
                guard generation == loadGeneration else { return }
                let mergedArticles = interactionStore.merge(loadedArticles)
                reduce(.setArticles(mergedArticles))
                reduce(.setPagination(nextSkip: mergedArticles.count, canLoadMore: loadedArticles.count == pageSize))
                reduce(.setState(makeStateForCurrentArticles(viewStateBuilder: viewStateBuilder)))
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                guard generation == loadGeneration else { return }
                reduce(.setState(.error(viewStateBuilder.makeError(from: error))))
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
        reduce(.setState(.refreshing(currentContent)))

        do {
            let refreshedArticles = try await repository.refreshNews(
                page: NewsPageRequest(limit: pageSize, skip: 0)
            )
            try Task.checkCancellation()
            guard generation == refreshGeneration else { return }
            let mergedArticles = interactionStore.merge(refreshedArticles)
            reduce(.setArticles(mergedArticles))
            reduce(.setPagination(nextSkip: mergedArticles.count, canLoadMore: refreshedArticles.count == pageSize))
            reduce(.setState(makeStateForCurrentArticles(viewStateBuilder: viewStateBuilder)))
        } catch is CancellationError {
            return
        } catch AppAPIError.cancelled {
            return
        } catch {
            guard generation == refreshGeneration else { return }
            var content = currentContent
            content.banner = AppStrings.text("Couldn’t refresh. Showing previous content.")
            reduce(.setState(.content(content)))
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
        reduce(.setState(.content(loadingContent)))

        loadNextPageTask = Task { [repository, interactionStore, viewStateBuilder] in
            defer { reduce(.clearLoadNextPageTask) }
            do {
                let nextPageArticles = try await repository.loadNews(page: request)
                try Task.checkCancellation()
                guard generation == paginationGeneration else { return }

                let mergedPage = interactionStore.merge(nextPageArticles)
                let mergedArticles = mergeExistingArticles(articles, with: mergedPage)
                reduce(.setArticles(mergedArticles))
                reduce(.setPagination(nextSkip: nextSkip + nextPageArticles.count, canLoadMore: nextPageArticles.count == pageSize))
                reduce(.setState(makeStateForCurrentArticles(viewStateBuilder: viewStateBuilder)))
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                guard generation == paginationGeneration else { return }
                guard case .content(let latestContent) = state else { return }
                var content = latestContent
                content.pagination = viewStateBuilder.makePaginationError(from: error)
                reduce(.setState(.content(content)))
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

        reduce(.setArticles(mergedArticles))
        let updatedCards = viewStateBuilder.makeContent(from: articles).cards

        switch state {
        case .content(let currentContent):
            reduce(.setState(.content(currentContent.replacingCards(updatedCards))))
        case .refreshing(let currentContent):
            reduce(.setState(.refreshing(currentContent.replacingCards(updatedCards))))
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
        reduce(.setArticles(articles.map { $0.id == articleID ? optimisticArticle : $0 }))

        var optimisticContent = content
        optimisticContent.cards = content.cards.map { item in
            guard item.id == articleID else { return item }
            return viewStateBuilder.makeCard(from: optimisticArticle)
        }
        reduce(.setState(.content(optimisticContent)))

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
                reduce(.setArticles(articles.map { $0.id == articleID ? optimisticArticle : $0 }))
                let updatedCard = viewStateBuilder.makeCard(from: optimisticArticle)

                guard case .content(let latestContent) = state else { return }
                var content = latestContent
                content.cards = latestContent.cards.map { $0.id == articleID ? updatedCard : $0 }
                reduce(.setState(.content(content)))
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
                reduce(.setState(.content(content)))
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
