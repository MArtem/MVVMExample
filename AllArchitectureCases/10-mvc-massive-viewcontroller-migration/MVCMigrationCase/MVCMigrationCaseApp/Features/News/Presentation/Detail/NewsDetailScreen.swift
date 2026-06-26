import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct NewsDetailScreen: View {
    @State private var controller: NewsDetailController

    init(controller: NewsDetailController) {
        _controller = State(initialValue: controller)
    }

    var body: some View {
        NewsDetailStateRenderer(
            state: controller.state,
            onRetryTap: controller.retryTapped,
            onFavoriteTap: controller.favoriteTapped
        )
        .navigationTitle(AppStrings.text("Details"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            controller.appeared()
        }
    }
}
