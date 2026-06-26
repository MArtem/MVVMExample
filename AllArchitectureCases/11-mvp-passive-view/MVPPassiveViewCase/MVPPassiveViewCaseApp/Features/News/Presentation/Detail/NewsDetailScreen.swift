import SwiftUI

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
