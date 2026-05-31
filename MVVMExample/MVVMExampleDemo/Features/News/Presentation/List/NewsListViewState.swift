import Foundation

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
    case updating
    case failed
}

struct MessageViewState: Equatable {
    let title: String
    let message: String
    let retryTitle: String
}
