import Foundation
import Observation

/// Owns article-detail state and detail-only user intents.
///
/// Ownership:
/// Created by the detail screen for one route payload.
///
/// Behavior:
/// Initial load can show a full-screen error. Favorite failures preserve visible content, roll back the optimistic state, and surface a non-blocking message.
@MainActor
@Observable
final class NewsDetailPresenter {
    private(set) var state: NewsDetailViewState

    private let payload: NewsDetailRoutePayload
    private let interactor: NewsDetailInteractor
    private let viewStateBuilder: NewsDetailViewStateBuilder
    private var article: NewsArticle?
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private var favoriteTask: Task<Void, Never>?
    private var loadGeneration = 0

    init(
        payload: NewsDetailRoutePayload,
        interactor: NewsDetailInteractor,
        viewStateBuilder: NewsDetailViewStateBuilder = NewsDetailViewStateBuilder()
    ) {
        self.payload = payload
        self.interactor = interactor
        self.viewStateBuilder = viewStateBuilder
        self.state = .loading(viewStateBuilder.makePlaceholder(from: payload))
    }

    deinit {
        loadTask?.cancel()
        favoriteTask?.cancel()
    }

    func appeared() {
        load()
    }

    func retryTapped() {
        load()
    }

    /// Toggles favorite state with optimistic UI and rollback on failure.
    func favoriteTapped() {
        toggleFavorite()
    }

    private func load() {
        loadTask?.cancel()
        loadGeneration += 1
        let generation = loadGeneration
        state = .loading(viewStateBuilder.makePlaceholder(from: payload))

        loadTask = Task { [interactor, viewStateBuilder, payload] in
            do {
                let loadedArticle = try await interactor.loadArticleDetail(id: payload.id)
                try Task.checkCancellation()
                guard generation == loadGeneration else { return }
                let mergedArticle = interactor.mergeInteractionState(into: loadedArticle)
                article = mergedArticle
                state = .content(viewStateBuilder.makeContent(from: mergedArticle))
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

    private func toggleFavorite() {
        guard let article else { return }
        guard favoriteTask == nil else { return }
        let target = !article.isLiked
        let optimisticArticle = article.replacingLikeState(isLiked: target)

        self.article = optimisticArticle
        interactor.persistOptimisticInteraction(optimisticArticle)
        state = .content(viewStateBuilder.makeContent(from: optimisticArticle))

        favoriteTask = Task { [interactor, viewStateBuilder] in
            defer { favoriteTask = nil }
            do {
                try await interactor.persistFavorite(articleID: article.id, isLiked: target)
                try Task.checkCancellation()
                interactor.acknowledgeFavoriteSuccess(optimisticArticle, articleID: article.id)
                let merged = interactor.mergeInteractionState(into: optimisticArticle)
                self.article = merged
                state = .content(viewStateBuilder.makeContent(from: merged))
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                interactor.enqueuePendingFavorite(articleID: article.id, isLiked: target)
                self.article = optimisticArticle
                state = .content(viewStateBuilder.makeContent(from: optimisticArticle))
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


/// VIPER Interactor for the article-detail module.
///
/// Owns article detail loading and durable favorite synchronization.
@MainActor
struct NewsDetailInteractor {
    private let repository: NewsRepository
    private let interactionStore: ArticleInteractionStore

    init(repository: NewsRepository, interactionStore: ArticleInteractionStore) {
        self.repository = repository
        self.interactionStore = interactionStore
    }

    func loadArticleDetail(id: NewsArticle.ID) async throws -> NewsArticle {
        try await repository.loadArticleDetail(id: id)
    }

    func persistFavorite(articleID: NewsArticle.ID, isLiked: Bool) async throws {
        _ = try await repository.toggleLike(articleID: articleID, isLiked: isLiked)
    }

    func mergeInteractionState(into article: NewsArticle) -> NewsArticle {
        interactionStore.merge(article)
    }

    func persistOptimisticInteraction(_ article: NewsArticle) {
        interactionStore.update(with: article)
    }

    func acknowledgeFavoriteSuccess(_ article: NewsArticle, articleID: NewsArticle.ID) {
        interactionStore.update(with: article)
        interactionStore.clearPendingLike(articleID: articleID)
    }

    func enqueuePendingFavorite(articleID: NewsArticle.ID, isLiked: Bool) {
        interactionStore.enqueuePendingLike(articleID: articleID, isLiked: isLiked)
    }
}
