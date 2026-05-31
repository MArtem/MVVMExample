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
            ratingText: AppStrings.formatted("Rating %.1f", article.rating),
            imageURL: article.imageURLs.first ?? article.thumbnailURL,
            likesText: AppStrings.formatted("%d likes", article.likesCount),
            commentsText: AppStrings.formatted("%d comments", article.commentsCount),
            isFavorite: article.isLiked
        )
    }

    func makeError(from error: Error) -> MessageViewState {
        MessageViewState(
            title: AppStrings.text("Couldn’t load details"),
            message: error.localizedDescription,
            retryTitle: AppStrings.text("Retry")
        )
    }
}
