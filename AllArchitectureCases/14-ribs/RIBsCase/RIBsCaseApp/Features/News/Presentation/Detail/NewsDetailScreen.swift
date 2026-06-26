import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct NewsDetailScreen: View {
    @State private var interactor: NewsDetailInteractor

    init(interactor: NewsDetailInteractor) {
        _interactor = State(initialValue: interactor)
    }

    var body: some View {
        NewsDetailStateRenderer(
            state: interactor.state,
            onRetryTap: interactor.retryTapped,
            onFavoriteTap: interactor.favoriteTapped
        )
        .navigationTitle(AppStrings.text("Details"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            interactor.appeared()
        }
    }
}
