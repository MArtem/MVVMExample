import Foundation

struct NewsPageRequest: Equatable, Sendable {
    let limit: Int
    let skip: Int
}

protocol NewsRepository {
    func loadNews(page: NewsPageRequest) async throws -> [NewsArticle]
    func refreshNews(page: NewsPageRequest) async throws -> [NewsArticle]
    func loadArticleDetail(id: NewsArticle.ID) async throws -> NewsArticle
    func toggleLike(articleID: NewsArticle.ID, isLiked: Bool) async throws -> NewsArticle
}

extension NewsRepository {
    func loadNews() async throws -> [NewsArticle] {
        try await loadNews(page: NewsPageRequest(limit: 30, skip: 0))
    }

    func refreshNews() async throws -> [NewsArticle] {
        try await refreshNews(page: NewsPageRequest(limit: 30, skip: 0))
    }
}
