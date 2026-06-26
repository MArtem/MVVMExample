import SwiftUI

struct NewsDetailScreen: View {
    @State private var store: NewsDetailPresenter

    init(store: NewsDetailPresenter) {
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
