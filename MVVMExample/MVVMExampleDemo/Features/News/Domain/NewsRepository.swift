import Foundation

protocol NewsRepository {
    func loadNews() async throws -> [NewsArticle]
    func refreshNews() async throws -> [NewsArticle]
    func loadArticleDetail(id: NewsArticle.ID) async throws -> NewsArticle
    func toggleLike(articleID: NewsArticle.ID, isLiked: Bool) async throws -> NewsArticle
}
