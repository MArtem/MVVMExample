import Foundation
import Observation

/// TCA semantic note:
/// The public `state` remains the rendered view state for SwiftUI compatibility, while feature-local `FeatureState` keeps non-rendered domain/cache/form state explicit so effects and reducers do not hide state-machine data in anonymous fields.
///
/// Owns article-detail state and detail-only user intents.
///
/// Ownership:
/// Created by the detail screen for one route payload.
///
/// Behavior:
/// Initial load can show a full-screen error. Favorite failures preserve visible content, roll back the optimistic state, and surface a non-blocking message.
@MainActor
@Observable
final class NewsDetailStore {
    struct FeatureState: Equatable {
        var loadedArticle: NewsArticle?
    }

    typealias State = NewsDetailViewState

    private enum Action {
        case appeared
        case retryTapped
        case favoriteTapped
    }

    private enum Effect {
        case loadDetail
        case toggleFavorite
    }

    private enum StateMutation {
        case setState(NewsDetailViewState)
        case setArticle(NewsArticle?)
    }

    private(set) var state: State

    private let payload: NewsDetailRoutePayload
    private let repository: NewsRepository
    private let viewStateBuilder: NewsDetailViewStateBuilder
    private let interactionStore: ArticleInteractionStore
    private var article: NewsArticle?
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private var favoriteTask: Task<Void, Never>?
    private var loadGeneration = 0

    init(
        payload: NewsDetailRoutePayload,
        repository: NewsRepository,
        interactionStore: ArticleInteractionStore,
        viewStateBuilder: NewsDetailViewStateBuilder = NewsDetailViewStateBuilder()
    ) {
        self.payload = payload
        self.repository = repository
        self.interactionStore = interactionStore
        self.viewStateBuilder = viewStateBuilder
        self.state = .loading(viewStateBuilder.makePlaceholder(from: payload))
    }

    deinit {
        loadTask?.cancel()
        favoriteTask?.cancel()
    }

    func appeared() {
        handle(.appeared)
    }

    func retryTapped() {
        handle(.retryTapped)
    }

    /// Toggles favorite state with optimistic UI and rollback on failure.
    func favoriteTapped() {
        handle(.favoriteTapped)
    }

    private func handle(_ action: Action) {
        switch action {
        case .appeared, .retryTapped:
            run(.loadDetail)
        case .favoriteTapped:
            run(.toggleFavorite)
        }
    }

    private func reduce(_ mutation: StateMutation) {
        switch mutation {
        case .setState(let state):
            self.state = state
        case .setArticle(let article):
            self.article = article
        }
    }

    private func run(_ effect: Effect) {
        switch effect {
        case .loadDetail:
            load()
        case .toggleFavorite:
            toggleFavorite()
        }
    }

    private func load() {
        loadTask?.cancel()
        loadGeneration += 1
        let generation = loadGeneration
        reduce(.setState(.loading(viewStateBuilder.makePlaceholder(from: payload))))

        loadTask = Task { [repository, interactionStore, viewStateBuilder, payload] in
            do {
                let loadedArticle = try await repository.loadArticleDetail(id: payload.id)
                try Task.checkCancellation()
                guard generation == loadGeneration else { return }
                let mergedArticle = interactionStore.merge(loadedArticle)
                reduce(.setArticle(mergedArticle))
                reduce(.setState(.content(viewStateBuilder.makeContent(from: mergedArticle))))
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

    private func toggleFavorite() {
        guard let article else { return }
        guard favoriteTask == nil else { return }
        let target = !article.isLiked
        let optimisticArticle = article.replacingLikeState(isLiked: target)

        reduce(.setArticle(optimisticArticle))
        interactionStore.update(with: optimisticArticle)
        reduce(.setState(.content(viewStateBuilder.makeContent(from: optimisticArticle))))

        favoriteTask = Task { [repository, interactionStore, viewStateBuilder] in
            defer { favoriteTask = nil }
            do {
                _ = try await repository.toggleLike(articleID: article.id, isLiked: target)
                try Task.checkCancellation()
                interactionStore.update(with: optimisticArticle)
                interactionStore.clearPendingLike(articleID: article.id)
                let merged = interactionStore.merge(optimisticArticle)
                reduce(.setArticle(merged))
                reduce(.setState(.content(viewStateBuilder.makeContent(from: merged))))
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                interactionStore.enqueuePendingLike(articleID: article.id, isLiked: target)
                reduce(.setArticle(optimisticArticle))
                reduce(.setState(.content(viewStateBuilder.makeContent(from: optimisticArticle))))
            }
        }
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
