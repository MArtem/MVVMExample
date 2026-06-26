import SwiftUI

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
