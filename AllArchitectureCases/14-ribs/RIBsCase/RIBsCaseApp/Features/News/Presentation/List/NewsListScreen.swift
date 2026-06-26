import SwiftUI

struct NewsListScreen: View {
    @State private var interactor: NewsListInteractor

    init(interactor: NewsListInteractor) {
        _interactor = State(initialValue: interactor)
    }

    var body: some View {
        NewsListStateRenderer(
            state: interactor.state,
            onRetryTap: interactor.retryTapped,
            onRefresh: interactor.refreshRequested,
            onArticleTap: interactor.articleTapped(id:),
            onLikeTap: interactor.likeTapped(id:),
            onCommentsTap: interactor.commentsTapped(id:),
            onItemAppear: interactor.loadNextPageIfNeeded(currentItemID:),
            onRetryLoadNextPageTap: interactor.retryLoadNextPageTapped
        )
        .navigationTitle(AppStrings.text("News"))
        .background(AppTheme.backgroundBase)
        .task {
            interactor.appeared()
        }
        .onAppear {
            interactor.becameVisible()
        }
    }
}

#Preview {
    NavigationStack {
        NewsListScreen(
            interactor: NewsListInteractor(
                repository: MockNewsRepository(),
                router: NewsRouter(),
                interactionStore: ArticleInteractionStore()
            )
        )
    }
}
