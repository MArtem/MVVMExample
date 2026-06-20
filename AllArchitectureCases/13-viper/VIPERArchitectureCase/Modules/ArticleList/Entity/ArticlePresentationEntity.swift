import Foundation

struct ArticlePresentationEntity: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let accessibilityLabel: String
}
