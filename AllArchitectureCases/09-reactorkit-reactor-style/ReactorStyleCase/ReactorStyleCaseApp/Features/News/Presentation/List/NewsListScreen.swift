import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct NewsListScreen: View {
    @State private var reactor: NewsListReactor

    init(reactor: NewsListReactor) {
        _reactor = State(initialValue: reactor)
    }

    var body: some View {
        NewsListStateRenderer(
            state: reactor.state,
            onRetryTap: reactor.retryTapped,
            onRefresh: reactor.refreshRequested,
            onArticleTap: reactor.articleTapped(id:),
            onLikeTap: reactor.likeTapped(id:),
            onCommentsTap: reactor.commentsTapped(id:),
            onItemAppear: reactor.loadNextPageIfNeeded(currentItemID:),
            onRetryLoadNextPageTap: reactor.retryLoadNextPageTapped
        )
        .navigationTitle(AppStrings.text("News"))
        .background(AppTheme.backgroundBase)
        .task {
            reactor.appeared()
        }
        .onAppear {
            reactor.becameVisible()
        }
    }
}

#Preview {
    NavigationStack {
        NewsListScreen(
            reactor: NewsListReactor(
                repository: MockNewsRepository(),
                router: NewsRouter(),
                interactionStore: ArticleInteractionStore()
            )
        )
    }
}
