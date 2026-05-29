import Foundation

enum NewsListAction: Equatable {
    case appeared
    case retryTapped
    case refreshRequested
    case cardTapped(Int)
    case likeTapped(Int)
    case commentsTapped(Int)
}

enum NewsCardAction: Equatable {
    case open
    case like
    case comments
}
