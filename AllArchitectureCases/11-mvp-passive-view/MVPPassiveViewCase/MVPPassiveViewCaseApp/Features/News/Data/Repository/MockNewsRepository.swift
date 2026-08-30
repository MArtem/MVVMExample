import Foundation

/// Preview/demo news repository with deterministic in-memory data.
///
/// Important:
/// This repository is for previews/demo seams and must not be wired silently into production runtime.
struct MockNewsRepository: NewsRepository {
    var articles: [NewsArticle] = [.fixture]
    var shouldFail = false

    func loadNews(page: NewsPageRequest) async throws -> [NewsArticle] {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        let end = min(page.skip + page.limit, articles.count)
        guard page.skip < end else { return [] }
        return Array(articles[page.skip..<end])
    }

    func refreshNews(page: NewsPageRequest) async throws -> [NewsArticle] {
        try await loadNews(page: page)
    }

    func loadArticleDetail(id: NewsArticle.ID) async throws -> NewsArticle {
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
        title: "MVP Passive View Navigation Architecture",
        excerpt: "A practical demo of typed routers, coordinators, repositories, DTO mapping and view state.",
        source: "DummyJSON",
        category: "architecture",
        rating: 4.8,
        thumbnailURL: URL(string: "https://dummyjson.com/image/400x200/282828/eaeaea?text=MVP"),
        imageURLs: [URL(string: "https://dummyjson.com/image/900x500/282828/eaeaea?text=MVP")!],
        publishedAt: .now.addingTimeInterval(-3600),
        likesCount: 48,
        commentsCount: 7,
        isLiked: false
    )
}
