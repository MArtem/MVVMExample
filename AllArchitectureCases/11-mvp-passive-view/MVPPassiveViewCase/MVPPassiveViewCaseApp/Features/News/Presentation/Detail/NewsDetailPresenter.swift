import Foundation
import Observation

/// MVP passive view presenter for article detail.
///
/// Ownership:
/// Created by the detail screen for one route payload.
///
/// MVP boundary:
/// This presenter owns article-detail presentation decisions, loading, favorite interaction, optimistic update, persistence merge, and repository calls. The SwiftUI detail screen remains passive/render-forwarding.
@MainActor
@Observable
final class NewsDetailPresenter {
    typealias State = NewsDetailViewState

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
        load()
    }

    func retryTapped() {
        load()
    }

    /// Toggles favorite state with optimistic UI and local pending sync fallback.
    func favoriteTapped() {
        toggleFavorite()
    }

    private func load() {
        loadTask?.cancel()
        loadGeneration += 1
        let generation = loadGeneration
        state = .loading(viewStateBuilder.makePlaceholder(from: payload))

        loadTask = Task { [repository, interactionStore, viewStateBuilder, payload] in
            do {
                let loadedArticle = try await repository.loadArticleDetail(id: payload.id)
                try Task.checkCancellation()
                guard generation == loadGeneration else { return }
                let mergedArticle = interactionStore.merge(loadedArticle)
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
        interactionStore.update(with: optimisticArticle)
        state = .content(viewStateBuilder.makeContent(from: optimisticArticle))

        favoriteTask = Task { [repository, interactionStore, viewStateBuilder] in
            defer { favoriteTask = nil }
            do {
                _ = try await repository.toggleLike(articleID: article.id, isLiked: target)
                try Task.checkCancellation()
                interactionStore.update(with: optimisticArticle)
                interactionStore.clearPendingLike(articleID: article.id)
                let merged = interactionStore.merge(optimisticArticle)
                self.article = merged
                state = .content(viewStateBuilder.makeContent(from: merged))
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                interactionStore.enqueuePendingLike(articleID: article.id, isLiked: target)
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
