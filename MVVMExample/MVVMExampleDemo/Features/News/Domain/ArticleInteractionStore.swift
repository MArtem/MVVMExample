import Foundation

/// Shared source of truth for article interaction state that must stay consistent across list and detail.
///
/// Ownership:
/// Created by the app dependency container and shared by news screens for the active app session.
///
/// Concurrency:
/// Main-actor isolated because current interactions are driven by UI intents and immediately reflected in SwiftUI state.
@MainActor
final class ArticleInteractionStore {
    private var states: [NewsArticle.ID: ArticleInteractionState] = [:]

    func merge(_ article: NewsArticle) -> NewsArticle {
        guard let state = states[article.id] else { return article }
        return article.applyingInteractionState(state)
    }

    func merge(_ articles: [NewsArticle]) -> [NewsArticle] {
        articles.map(merge)
    }

    func setLikeState(articleID: NewsArticle.ID, isLiked: Bool, likesCount: Int) {
        states[articleID] = ArticleInteractionState(
            isLiked: isLiked,
            likesCount: max(0, likesCount)
        )
    }

    func update(with article: NewsArticle) {
        setLikeState(
            articleID: article.id,
            isLiked: article.isLiked,
            likesCount: article.likesCount
        )
    }
}

private struct ArticleInteractionState {
    let isLiked: Bool
    let likesCount: Int
}

private extension NewsArticle {
    func applyingInteractionState(_ state: ArticleInteractionState) -> NewsArticle {
        NewsArticle(
            id: id,
            title: title,
            excerpt: excerpt,
            source: source,
            category: category,
            rating: rating,
            thumbnailURL: thumbnailURL,
            imageURLs: imageURLs,
            publishedAt: publishedAt,
            likesCount: state.likesCount,
            commentsCount: commentsCount,
            isLiked: state.isLiked
        )
    }
}
