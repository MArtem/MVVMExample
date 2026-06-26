import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct NewsDetailScreen: View {
    @State private var presenter: NewsDetailPresenter

    init(presenter: NewsDetailPresenter) {
        _presenter = State(initialValue: presenter)
    }

    var body: some View {
        NewsDetailStateRenderer(
            state: presenter.state,
            onRetryTap: presenter.retryTapped,
            onFavoriteTap: presenter.favoriteTapped
        )
        .navigationTitle(AppStrings.text("Details"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            presenter.appeared()
        }
    }
}
