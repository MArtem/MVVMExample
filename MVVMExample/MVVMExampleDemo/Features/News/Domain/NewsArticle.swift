import Foundation

struct NewsArticle: Identifiable, Equatable, Sendable {
    let id: Int
    let title: String
    let excerpt: String
    let source: String
    let category: String
    let rating: Double
    let thumbnailURL: URL?
    let imageURLs: [URL]
    let publishedAt: Date?
    let likesCount: Int
    let commentsCount: Int
    let isLiked: Bool
}
