import SwiftUI

struct NewsListScreen: View {
    @State private var presenter: NewsListPresenter

    init(presenter: NewsListPresenter) {
        _presenter = State(initialValue: presenter)
    }

    var body: some View {
        NewsListStateRenderer(
            state: presenter.state,
            onRetryTap: presenter.retryTapped,
            onRefresh: presenter.refreshRequested,
            onArticleTap: presenter.articleTapped(id:),
            onLikeTap: presenter.likeTapped(id:),
            onCommentsTap: presenter.commentsTapped(id:),
            onItemAppear: presenter.loadNextPageIfNeeded(currentItemID:),
            onRetryLoadNextPageTap: presenter.retryLoadNextPageTapped
        )
        .navigationTitle(AppStrings.text("News"))
        .background(AppTheme.backgroundBase)
        .task {
            presenter.appeared()
        }
        .onAppear {
            presenter.becameVisible()
        }
    }
}

#Preview {
    NavigationStack {
        NewsListScreen(
            presenter: NewsListPresenter(
                repository: MockNewsRepository(),
                router: NewsRouter(),
                interactionStore: ArticleInteractionStore()
            )
        )
    }
}
