import Foundation
import Observation
import AppErrors
import AppLocalization

@MainActor
@Observable
final class NewsListViewModel {
    private(set) var state: NewsListViewState = .idle

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

    func appeared() {
        loadIfNeeded()
    }

    func retryTapped() {
        load()
    }

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

    func loadNextPageIfNeeded(currentItemID: NewsArticle.ID) {
        guard shouldLoadNextPage(currentItemID: currentItemID) else { return }
        loadNextPage()
    }

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
                articles = interactionStore.merge(loadedArticles)
                nextSkip = articles.count
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
            articles = interactionStore.merge(refreshedArticles)
            nextSkip = articles.count
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
                articles = mergeExistingArticles(articles, with: mergedPage)
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

        let targetIsLiked: Bool
        switch card.likeState {
        case .liked:
            targetIsLiked = false
        case .notLiked, .failed:
            targetIsLiked = true
        case .updating:
            return
        }

        likeTasks[articleID]?.cancel()

        var optimisticContent = content
        optimisticContent.cards = content.cards.map { item in
            guard item.id == articleID else { return item }
            return item.replacingLikeState(.updating)
        }
        state = .content(optimisticContent)

        likeTasks[articleID] = Task { [repository, interactionStore, viewStateBuilder] in
            defer { likeTasks[articleID] = nil }
            do {
                let updatedArticle = try await repository.toggleLike(
                    articleID: articleID,
                    isLiked: targetIsLiked
                )
                try Task.checkCancellation()
                interactionStore.update(with: updatedArticle)
                articles = articles.map { $0.id == articleID ? updatedArticle : $0 }
                let updatedCard = viewStateBuilder.makeCard(from: updatedArticle)

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
                content.cards = latestContent.cards.map { item in
                    item.id == articleID ? item.replacingLikeState(.failed) : item
                }
                content.banner = AppStrings.text("Couldn’t update like. Please try again.")
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
