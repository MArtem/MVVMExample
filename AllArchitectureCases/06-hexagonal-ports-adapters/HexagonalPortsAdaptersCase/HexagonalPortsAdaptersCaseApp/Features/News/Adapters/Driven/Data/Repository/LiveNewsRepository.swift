import Foundation

/// Live news repository backed by the configured API client.
///
/// Boundary behavior:
/// Transport DTOs are mapped to domain articles before leaving this type.
struct LiveNewsRepository: NewsRepository {
    private let apiClient: APIClient
    private let mapper: NewsDTOMapper

    init(apiClient: APIClient, mapper: NewsDTOMapper = NewsDTOMapper()) {
        self.apiClient = apiClient
        self.mapper = mapper
    }

    func loadNews(page: NewsPageRequest) async throws -> [NewsArticle] {
        let response: ProductsResponseDTO = try await apiClient.send(
            ProductsListRequest(limit: page.limit, skip: page.skip)
        )
        return try response.products.map(mapper.map)
    }

    func refreshNews(page: NewsPageRequest) async throws -> [NewsArticle] {
        try await loadNews(page: page)
    }

    func loadArticleDetail(id: NewsArticle.ID) async throws -> NewsArticle {
        let response: ProductDTO = try await apiClient.send(ProductDetailRequest(id: id))
        return try mapper.map(response)
    }

    func toggleLike(articleID: NewsArticle.ID, isLiked: Bool) async throws -> NewsArticle {
        let response: ProductDTO = try await apiClient.send(
            UpdateProductLikeRequest(id: articleID, isLiked: isLiked)
        )
        var article = try mapper.map(response)
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
