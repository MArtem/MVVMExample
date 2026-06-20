import Foundation

/// Complete render state for the news list screen.
///
/// Invariant:
/// Full-screen errors are used only when no usable content is available; refresh and pagination failures keep existing content visible.
enum NewsListViewState: Equatable {
    case idle
    case loading
    case content(NewsListContentViewState)
    case refreshing(NewsListContentViewState)
    case empty(MessageViewState)
    case error(MessageViewState)
}

struct NewsListContentViewState: Equatable {
    var cards: [NewsCardViewState]
    var banner: String?
    var pagination: NewsPaginationViewState
}

struct NewsPaginationViewState: Equatable {
    enum Status: Equatable {
        case idle
        case loading
        case error(message: String, retryTitle: String)
        case endReached(message: String)
    }

    var status: Status
}

/// Precomputed row state for a news card.
///
/// Performance contract:
/// Values that require formatting, uppercasing, icon selection, or accessibility text assembly are prepared before SwiftUI row rendering.
struct NewsCardViewState: Identifiable, Equatable {
    let id: Int
    let sourceText: String
    let sourceDisplayText: String
    let title: String
    let excerpt: String
    let publishedAtText: String
    let thumbnailURL: URL?
    let likesText: String
    let commentsText: String
    let likeState: LikeButtonState
    let likeIconName: String
    let accessibilityLabel: String
    let likeAccessibilityLabel: String
    let commentsAccessibilityLabel: String
}

enum LikeButtonState: Equatable {
    case notLiked
    case liked
    case failed
}

struct MessageViewState: Equatable {
    let title: String
    let message: String
    let retryTitle: String
}
