import SwiftUI

struct NewsListScreen: View {
    @State private var store: NewsListPresenter

    init(store: NewsListPresenter) {
        _store = State(initialValue: store)
    }

    var body: some View {
        NewsListStateRenderer(
            state: store.state,
            onRetryTap: store.retryTapped,
            onRefresh: store.refreshRequested,
            onArticleTap: store.articleTapped(id:),
            onLikeTap: store.likeTapped(id:),
            onCommentsTap: store.commentsTapped(id:),
            onItemAppear: store.loadNextPageIfNeeded(currentItemID:),
            onRetryLoadNextPageTap: store.retryLoadNextPageTapped
        )
        .navigationTitle(AppStrings.text("News"))
        .background(AppTheme.backgroundBase)
        .task {
            store.appeared()
        }
        .onAppear {
            store.becameVisible()
        }
    }
}

#Preview {
    NavigationStack {
        NewsListScreen(
            store: NewsListPresenter(
                repository: MockNewsRepository(),
                router: NewsRouter(),
                interactionStore: ArticleInteractionStore()
            )
        )
    }
}
