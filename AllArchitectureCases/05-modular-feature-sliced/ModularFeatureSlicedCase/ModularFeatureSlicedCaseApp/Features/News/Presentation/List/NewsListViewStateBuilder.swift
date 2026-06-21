import Foundation

/// Maps domain articles and errors into list presentation state.
///
/// Boundary rule:
/// Formatting and localized user-facing messages are prepared here rather than inside row bodies.
struct NewsListViewStateBuilder {
    private let relativeDateFormatter: RelativeDateTimeFormatter

    init(relativeDateFormatter: RelativeDateTimeFormatter = RelativeDateTimeFormatter()) {
        self.relativeDateFormatter = relativeDateFormatter
        self.relativeDateFormatter.unitsStyle = .short
    }

    func makeContent(from articles: [NewsArticle]) -> NewsListContentViewState {
        NewsListContentViewState(
            cards: articles.map(makeCard),
            banner: nil,
            pagination: makePaginationIdle()
        )
    }

    func makePaginationIdle() -> NewsPaginationViewState {
        NewsPaginationViewState(status: .idle)
    }

    func makePaginationLoading() -> NewsPaginationViewState {
        NewsPaginationViewState(status: .loading)
    }

    func makePaginationError(from error: Error) -> NewsPaginationViewState {
        NewsPaginationViewState(
            status: .error(
                message: AppErrorMapper.userMessage(for: error),
                retryTitle: AppStrings.text("Retry loading more")
            )
        )
    }

    func makePaginationEndReached() -> NewsPaginationViewState {
        NewsPaginationViewState(status: .endReached(message: AppStrings.text("You’re all caught up")))
    }

    func makeEmpty() -> MessageViewState {
        MessageViewState(
            title: AppStrings.text("No news yet"),
            message: AppStrings.text("New cards will appear here when the API returns data."),
            retryTitle: AppStrings.text("Retry")
        )
    }

    func makeError(from error: Error) -> MessageViewState {
        MessageViewState(
            title: AppStrings.text("Couldn’t load news"),
            message: AppErrorMapper.userMessage(for: error),
            retryTitle: AppStrings.text("Retry")
        )
    }

    func makeCard(from article: NewsArticle) -> NewsCardViewState {
        let dateText: String
        if let publishedAt = article.publishedAt {
            dateText = relativeDateFormatter.localizedString(for: publishedAt, relativeTo: .now)
        } else {
            dateText = AppStrings.text("Recently")
        }

        let likeIconName = Self.likeIconName(for: article.isLiked ? .liked : .notLiked)
        let commentsText = AppStrings.formatted("Comments %@", AppStrings.localizedNumber(article.commentsCount))

        return NewsCardViewState(
            id: article.id,
            sourceText: article.source,
            sourceDisplayText: article.source.uppercased(with: .current),
            title: article.title,
            excerpt: article.excerpt,
            publishedAtText: dateText,
            thumbnailURL: article.thumbnailURL,
            likesText: AppStrings.localizedNumber(article.likesCount),
            commentsText: commentsText,
            likeState: article.isLiked ? .liked : .notLiked,
            likeIconName: likeIconName,
            accessibilityLabel: AppStrings.formatted("%@. %@. %@.", article.source, article.title, dateText),
            likeAccessibilityLabel: article.isLiked ? AppStrings.text("Unlike article") : AppStrings.text("Like article"),
            commentsAccessibilityLabel: commentsText
        )
    }

    static func likeIconName(for likeState: LikeButtonState) -> String {
        switch likeState {
        case .liked:
            return "hand.thumbsup.fill"
        case .notLiked, .failed:
            return "hand.thumbsup"
        }
    }
}
