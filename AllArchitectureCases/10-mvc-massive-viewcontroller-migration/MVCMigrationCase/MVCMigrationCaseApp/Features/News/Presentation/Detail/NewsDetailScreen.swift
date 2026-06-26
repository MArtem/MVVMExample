import SwiftUI

struct NewsDetailScreen: View {
    @State private var store: NewsDetailController

    init(store: NewsDetailController) {
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
