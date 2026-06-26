import SwiftUI

struct NewsDetailScreen: View {
    @State private var reactor: NewsDetailReactor

    init(reactor: NewsDetailReactor) {
        _reactor = State(initialValue: reactor)
    }

    var body: some View {
        NewsDetailStateRenderer(
            state: reactor.state,
            onRetryTap: reactor.retryTapped,
            onFavoriteTap: reactor.favoriteTapped
        )
        .navigationTitle(AppStrings.text("Details"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            reactor.appeared()
        }
    }
}
