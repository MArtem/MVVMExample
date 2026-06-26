import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct NewsDetailScreen: View {
    @State private var model: NewsDetailModel

    init(model: NewsDetailModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        NewsDetailStateRenderer(
            state: model.state,
            onRetryTap: model.retryTapped,
            onFavoriteTap: model.favoriteTapped
        )
        .navigationTitle(AppStrings.text("Details"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            model.appeared()
        }
    }
}
