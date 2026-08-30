import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct NewsDetailScreen: View {
    @State private var viewModel: NewsDetailViewModel

    init(viewModel: NewsDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NewsDetailStateRenderer(
            state: viewModel.state,
            onRetryTap: viewModel.retryTapped,
            onFavoriteTap: viewModel.favoriteTapped
        )
        .navigationTitle(AppStrings.text("Details"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.appeared()
        }
    }
}
