import SwiftUI

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
