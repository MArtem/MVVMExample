import Foundation

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
    let isFavoriteUpdating: Bool
    let favoriteErrorMessage: String?
}
