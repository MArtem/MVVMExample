import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct NewsDetailScreen: View {
    @State private var reactor: NewsDetailReactor

    init(reactor: NewsDetailReactor) {
        _reactor = State(initialValue: reactor)
    }

    var body: some View {
        NewsDetailStateRenderer(
            state: reactor.state,
            onRetryTap: reactor.retryTapped,
            onFavoriteTap: reactor.favoriteTapped
        )
        .navigationTitle(AppStrings.text("Details"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            reactor.appeared()
        }
    }
}
