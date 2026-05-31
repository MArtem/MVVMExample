import Foundation

struct NewsListViewStateBuilder {
    private let relativeDateFormatter: RelativeDateTimeFormatter

    init(relativeDateFormatter: RelativeDateTimeFormatter = RelativeDateTimeFormatter()) {
        self.relativeDateFormatter = relativeDateFormatter
        self.relativeDateFormatter.unitsStyle = .short
    }

    func makeContent(from articles: [NewsArticle]) -> NewsListContentViewState {
        NewsListContentViewState(
            cards: articles.map(makeCard),
            banner: nil
        )
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
            message: error.localizedDescription,
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

        return NewsCardViewState(
            id: article.id,
            sourceText: article.source,
            title: article.title,
            excerpt: article.excerpt,
            publishedAtText: dateText,
            thumbnailURL: article.thumbnailURL,
            likesText: "\(article.likesCount)",
            commentsText: AppStrings.formatted("%d comments", article.commentsCount),
            likeState: article.isLiked ? .liked : .notLiked,
            accessibilityLabel: "\(article.source). \(article.title). \(dateText)."
        )
    }
}
