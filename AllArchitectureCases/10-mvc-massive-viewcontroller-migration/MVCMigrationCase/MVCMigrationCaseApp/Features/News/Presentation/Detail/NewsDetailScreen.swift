import SwiftUI

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
