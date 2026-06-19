import Foundation

/// Complete render state for article detail.
///
/// Invariant:
/// Interaction failures should use `NewsDetailContentViewState.favoriteErrorMessage` when content is already available.
enum NewsDetailViewState: Equatable {
    case loading(NewsDetailPlaceholderViewState)
    case content(NewsDetailContentViewState)
    case error(MessageViewState)
}

struct NewsDetailPlaceholderViewState: Equatable {
    let title: String
    let thumbnailURL: URL?
}

struct NewsDetailContentViewState: Equatable {
    let id: Int
    let title: String
    let excerpt: String
    let sourceText: String
    let categoryText: String
    let ratingText: String
    let imageURL: URL?
    let likesText: String
    let commentsText: String
    let isFavorite: Bool
    let favoriteErrorMessage: String?
}
