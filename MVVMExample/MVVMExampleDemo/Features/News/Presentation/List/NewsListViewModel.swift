import Foundation
import Observation

@MainActor
@Observable
final class NewsListViewModel {
    private(set) var state: NewsListViewState = .idle

    private let repository: NewsRepository
    private let viewStateBuilder: NewsListViewStateBuilder
    private let interactionStore: ArticleInteractionStore
    private weak var router: NewsRouter?
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private var refreshTask: Task<Void, Never>?
    @ObservationIgnored private var likeTasks: [NewsArticle.ID: Task<Void, Never>] = [:]
    private var loadGeneration = 0
    private var refreshGeneration = 0

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
        refreshTask?.cancel()
        likeTasks.values.forEach { $0.cancel() }
    }

    func appeared() {
        loadIfNeeded()
    }

    func retryTapped() {
        load()
    }

    func refreshRequested() {
        refresh()
    }

    func articleTapped(id: NewsArticle.ID) {
        openDetail(id: id)
    }

    func likeTapped(id: NewsArticle.ID) {
        toggleLike(articleID: id)
    }

    func commentsTapped(id: NewsArticle.ID) {
        // Comments are visible as counts only in the current demo scope.
    }

    private func loadIfNeeded() {
        guard case .idle = state else { return }
        load()
    }

    private func load() {
        loadTask?.cancel()
        loadGeneration += 1
        let generation = loadGeneration
        state = .loading

        loadTask = Task { [repository, interactionStore, viewStateBuilder] in
            do {
                let articles = try await repository.loadNews()
                try Task.checkCancellation()
                guard generation == loadGeneration else { return }
                let merged = interactionStore.merge(articles)
                state = merged.isEmpty
                    ? .empty(viewStateBuilder.makeEmpty())
                    : .content(viewStateBuilder.makeContent(from: merged))
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

    private func refresh() {
        guard case .content(let currentContent) = state else {
            load()
            return
        }

        refreshTask?.cancel()
        refreshGeneration += 1
        let generation = refreshGeneration
        state = .refreshing(currentContent)

        refreshTask = Task { [repository, interactionStore, viewStateBuilder] in
            do {
                let articles = try await repository.refreshNews()
                try Task.checkCancellation()
                guard generation == refreshGeneration else { return }
                let merged = interactionStore.merge(articles)
                state = merged.isEmpty
                    ? .empty(viewStateBuilder.makeEmpty())
                    : .content(viewStateBuilder.makeContent(from: merged))
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
            title: title,
            excerpt: excerpt,
            publishedAtText: publishedAtText,
            thumbnailURL: thumbnailURL,
            likesText: likesText,
            commentsText: commentsText,
            likeState: likeState,
            accessibilityLabel: accessibilityLabel
        )
    }
}
