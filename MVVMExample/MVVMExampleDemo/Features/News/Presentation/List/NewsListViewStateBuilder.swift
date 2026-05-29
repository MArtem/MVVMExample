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
            title: "No news yet",
            message: "New cards will appear here when the API returns data.",
            retryTitle: "Retry"
        )
    }

    func makeError(from error: Error) -> MessageViewState {
        MessageViewState(
            title: "Couldn’t load news",
            message: error.localizedDescription,
            retryTitle: "Retry"
        )
    }

    func makeCard(from article: NewsArticle) -> NewsCardViewState {
        let dateText: String
        if let publishedAt = article.publishedAt {
            dateText = relativeDateFormatter.localizedString(for: publishedAt, relativeTo: .now)
        } else {
            dateText = "Recently"
        }

        return NewsCardViewState(
            id: article.id,
            sourceText: article.source,
            title: article.title,
            excerpt: article.excerpt,
            publishedAtText: dateText,
            thumbnailURL: article.thumbnailURL,
            likesText: "\(article.likesCount)",
            commentsText: "\(article.commentsCount) comments",
            likeState: article.isLiked ? .liked : .notLiked,
            accessibilityLabel: "\(article.source). \(article.title). \(dateText)."
        )
    }
}
