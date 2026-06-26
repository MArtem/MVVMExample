import SwiftUI

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
