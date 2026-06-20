import Foundation

struct ArticleEntity: Identifiable, Equatable, Sendable {
    let id: UUID
    let title: String
    let summary: String
    let readingMinutes: Int
}
