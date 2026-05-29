import Foundation

struct NewsDetailViewStateBuilder {
    func makePlaceholder(from payload: NewsDetailRoutePayload) -> NewsDetailPlaceholderViewState {
        NewsDetailPlaceholderViewState(
            title: payload.title,
            thumbnailURL: payload.thumbnailURL
        )
    }

    func makeContent(from article: NewsArticle) -> NewsDetailContentViewState {
        NewsDetailContentViewState(
            id: article.id,
            title: article.title,
            excerpt: article.excerpt,
            sourceText: article.source,
            categoryText: article.category.capitalized,
            ratingText: String(format: "Rating %.1f", article.rating),
            imageURL: article.imageURLs.first ?? article.thumbnailURL,
            likesText: "\(article.likesCount) likes",
            commentsText: "\(article.commentsCount) comments",
            isFavorite: article.isLiked
        )
    }

    func makeError(from error: Error) -> MessageViewState {
        MessageViewState(
            title: "Couldn’t load details",
            message: error.localizedDescription,
            retryTitle: "Retry"
        )
    }
}
