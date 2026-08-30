import Foundation

/// Maps article domain state and errors into detail presentation state.
struct NewsDetailPresenter {
    func makePlaceholder(from payload: NewsDetailRoutePayload) -> NewsDetailPlaceholderViewState {
        NewsDetailPlaceholderViewState(
            title: payload.title,
            thumbnailURL: payload.thumbnailURL
        )
    }

    func makeContent(
        from article: NewsArticle,
        favoriteErrorMessage: String? = nil
    ) -> NewsDetailContentViewState {
        NewsDetailContentViewState(
            id: article.id,
            title: article.title,
            excerpt: article.excerpt,
            sourceText: article.source,
            categoryText: article.category == "general" ? AppStrings.text("General") : article.category.capitalized(with: .current),
            ratingText: AppStrings.formatted("Rating %@", AppStrings.localizedNumber(article.rating)),
            imageURL: article.imageURLs.first ?? article.thumbnailURL,
            likesText: AppStrings.formatted("Likes %@", AppStrings.localizedNumber(article.likesCount)),
            commentsText: AppStrings.formatted("Comments %@", AppStrings.localizedNumber(article.commentsCount)),
            isFavorite: article.isLiked,
            favoriteErrorMessage: favoriteErrorMessage
        )
    }

    func makeError(from error: Error) -> MessageViewState {
        MessageViewState(
            title: AppStrings.text("Couldn’t load details"),
            message: AppErrorMapper.userMessage(for: error),
            retryTitle: AppStrings.text("Retry")
        )
    }
}
