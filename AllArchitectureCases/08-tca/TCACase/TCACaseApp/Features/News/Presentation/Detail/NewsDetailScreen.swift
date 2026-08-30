import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct NewsDetailScreen: View {
    @State private var store: NewsDetailStore

    init(store: NewsDetailStore) {
        _store = State(initialValue: store)
    }

    var body: some View {
        NewsDetailStateRenderer(
            state: store.state,
            onRetryTap: store.retryTapped,
            onFavoriteTap: store.favoriteTapped
        )
        .navigationTitle(AppStrings.text("Details"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            store.appeared()
        }
    }
}
