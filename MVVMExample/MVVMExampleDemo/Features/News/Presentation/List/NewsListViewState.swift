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
}

struct NewsCardViewState: Identifiable, Equatable {
    let id: Int
    let sourceText: String
    let title: String
    let excerpt: String
    let publishedAtText: String
    let thumbnailURL: URL?
    let likesText: String
    let commentsText: String
    let likeState: LikeButtonState
    let accessibilityLabel: String
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
