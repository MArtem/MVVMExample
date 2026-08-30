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

/// Render-ready presentation state consumed by SwiftUI views.
///
/// Formatting policy: expensive localization, date, number, and accessibility strings should be prepared before row/body rendering hot paths.
struct NewsDetailPlaceholderViewState: Equatable {
    let title: String
    let thumbnailURL: URL?
}

/// Render-ready presentation state consumed by SwiftUI views.
///
/// Formatting policy: expensive localization, date, number, and accessibility strings should be prepared before row/body rendering hot paths.
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
