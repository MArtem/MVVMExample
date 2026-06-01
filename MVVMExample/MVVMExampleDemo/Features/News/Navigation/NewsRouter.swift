import SwiftUI
import Observation

/// Navigation owner for the news feature stack.
///
/// Ownership:
/// Owned by `MainCoordinator` for the authenticated app session.
@MainActor
@Observable
final class NewsRouter {
    var path = NavigationPath()

    func openDetail(_ payload: NewsDetailRoutePayload) {
        path.append(NewsRoute.detail(payload))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func reset() {
        path = NavigationPath()
    }
}

enum NewsRoute: Hashable {
    case detail(NewsDetailRoutePayload)
}

struct NewsDetailRoutePayload: Hashable, Identifiable {
    let id: Int
    let title: String
    let thumbnailURL: URL?
}
