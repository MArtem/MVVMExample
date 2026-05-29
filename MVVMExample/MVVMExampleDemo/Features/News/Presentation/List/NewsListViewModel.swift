import Foundation
import Observation

@MainActor
@Observable
final class NewsListViewModel {
    private(set) var state: NewsListViewState = .idle

    private let repository: NewsRepository
    private let viewStateBuilder: NewsListViewStateBuilder
    private weak var router: NewsRouter?
    private var loadTask: Task<Void, Never>?

    init(
        repository: NewsRepository,
        router: NewsRouter,
        viewStateBuilder: NewsListViewStateBuilder = NewsListViewStateBuilder()
    ) {
        self.repository = repository
        self.router = router
        self.viewStateBuilder = viewStateBuilder
    }

    func send(_ action: NewsListAction) {
        switch action {
        case .appeared:
            loadIfNeeded()

        case .retryTapped:
            load()

        case .refreshRequested:
            refresh()

        case .cardTapped(let id):
            openDetail(id: id)

        case .likeTapped(let id):
            toggleLike(articleID: id)

        case .commentsTapped:
            break
        }
    }

    private func loadIfNeeded() {
        guard case .idle = state else { return }
        load()
    }

    private func load() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task {
            do {
                let articles = try await repository.loadNews()
                try Task.checkCancellation()
                state = articles.isEmpty
                    ? .empty(viewStateBuilder.makeEmpty())
                    : .content(viewStateBuilder.makeContent(from: articles))
            } catch is CancellationError {
                return
            } catch {
                state = .error(viewStateBuilder.makeError(from: error))
            }
        }
    }

    private func refresh() {
        guard case .content(let currentContent) = state else {
            load()
            return
        }

        loadTask?.cancel()
        state = .refreshing(currentContent)

        loadTask = Task {
            do {
                let articles = try await repository.refreshNews()
                try Task.checkCancellation()
                state = articles.isEmpty
                    ? .empty(viewStateBuilder.makeEmpty())
                    : .content(viewStateBuilder.makeContent(from: articles))
            } catch is CancellationError {
                return
            } catch {
                var content = currentContent
                content.banner = "Couldn’t refresh. Showing previous content."
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

        var optimisticContent = content
        optimisticContent.cards = content.cards.map { item in
            guard item.id == articleID else { return item }
            return item.replacingLikeState(.updating)
        }
        state = .content(optimisticContent)

        Task {
            do {
                let updatedArticle = try await repository.toggleLike(
                    articleID: articleID,
                    isLiked: targetIsLiked
                )
                try Task.checkCancellation()
                let updatedCard = viewStateBuilder.makeCard(from: updatedArticle)

                guard case .content(let latestContent) = state else { return }
                var content = latestContent
                content.cards = latestContent.cards.map { $0.id == articleID ? updatedCard : $0 }
                state = .content(content)
            } catch is CancellationError {
                return
            } catch {
                guard case .content(let latestContent) = state else { return }
                var content = latestContent
                content.cards = latestContent.cards.map { item in
                    item.id == articleID ? item.replacingLikeState(.failed) : item
                }
                content.banner = "Couldn’t update like. Please try again."
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
