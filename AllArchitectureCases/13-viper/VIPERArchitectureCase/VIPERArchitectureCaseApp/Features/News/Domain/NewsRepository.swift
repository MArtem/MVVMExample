import Foundation

/// Cursor-style page request for the current DummyJSON-compatible list API.
///
/// Invariant:
/// `skip` is the number of already requested items and `limit` is the requested page size.
struct NewsPageRequest: Equatable, Sendable {
    let limit: Int
    let skip: Int
}

/// News feature data boundary.
///
/// Responsibilities:
/// - expose domain `NewsArticle` values;
/// - hide DTO, pagination request, and API mutation details from Presenters;
/// - keep list, detail, and like/favorite operations behind one feature contract.
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
