import Foundation

enum NewsMappingError: Error {
    case missingID
    case missingTitle
}

struct NewsDTOMapper {
    func map(_ dto: ProductDTO) throws -> NewsArticle {
        guard let id = dto.id else {
            throw NewsMappingError.missingID
        }

        guard let title = dto.title, !title.isEmpty else {
            throw NewsMappingError.missingTitle
        }

        let createdAt = dto.meta?.createdAt.flatMap(ISO8601DateFormatter().date(from:))
        let imageURLs = (dto.images ?? []).compactMap(URL.init(string:))
        let thumbnailURL = dto.thumbnail.flatMap(URL.init(string:)) ?? imageURLs.first
        let reviewsCount = dto.reviews?.count ?? 0
        let syntheticLikes = max(0, Int((dto.rating ?? 0) * 10))

        return NewsArticle(
            id: id,
            title: title,
            excerpt: dto.description ?? "",
            source: dto.brand ?? "DummyJSON",
            category: dto.category ?? "general",
            rating: dto.rating ?? 0,
            thumbnailURL: thumbnailURL,
            imageURLs: imageURLs,
            publishedAt: createdAt,
            likesCount: syntheticLikes,
            commentsCount: reviewsCount,
            isLiked: false
        )
    }
}
