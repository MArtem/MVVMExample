import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct NewsListScreen: View {
    @State private var store: NewsListStore

    init(store: NewsListStore) {
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
            store: NewsListStore(
                repository: MockNewsRepository(),
                router: NewsRouter(),
                interactionStore: ArticleInteractionStore()
            )
        )
    }
}
