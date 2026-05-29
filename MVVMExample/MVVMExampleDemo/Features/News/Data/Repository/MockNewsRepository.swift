import Foundation

struct MockNewsRepository: NewsRepository {
    var articles: [NewsArticle] = [.fixture]
    var shouldFail = false

    func loadNews() async throws -> [NewsArticle] {
        try await Task.sleep(for: .milliseconds(250))
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return articles
    }

    func refreshNews() async throws -> [NewsArticle] {
        try await loadNews()
    }

    func loadArticleDetail(id: NewsArticle.ID) async throws -> NewsArticle {
        try await Task.sleep(for: .milliseconds(250))
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return articles.first(where: { $0.id == id }) ?? .fixture
    }

    func toggleLike(articleID: NewsArticle.ID, isLiked: Bool) async throws -> NewsArticle {
        var article = articles.first(where: { $0.id == articleID }) ?? .fixture
        article = NewsArticle(
            id: article.id,
            title: article.title,
            excerpt: article.excerpt,
            source: article.source,
            category: article.category,
            rating: article.rating,
            thumbnailURL: article.thumbnailURL,
            imageURLs: article.imageURLs,
            publishedAt: article.publishedAt,
            likesCount: isLiked ? article.likesCount + 1 : max(0, article.likesCount - 1),
            commentsCount: article.commentsCount,
            isLiked: isLiked
        )
        return article
    }
}

extension NewsArticle {
    static let fixture = NewsArticle(
        id: 1,
        title: "SwiftUI MVVM Navigation Architecture",
        excerpt: "A practical demo of typed routers, coordinators, repositories, DTO mapping and view state.",
        source: "DummyJSON",
        category: "architecture",
        rating: 4.8,
        thumbnailURL: URL(string: "https://dummyjson.com/image/400x200/282828/eaeaea?text=MVVM"),
        imageURLs: [URL(string: "https://dummyjson.com/image/900x500/282828/eaeaea?text=MVVM")!],
        publishedAt: .now.addingTimeInterval(-3600),
        likesCount: 48,
        commentsCount: 7,
        isLiked: false
    )
}
