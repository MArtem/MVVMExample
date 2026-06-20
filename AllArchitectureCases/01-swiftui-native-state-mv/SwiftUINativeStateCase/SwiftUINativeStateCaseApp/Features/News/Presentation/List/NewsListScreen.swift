import SwiftUI

struct NewsListScreen: View {
    @State private var model: NewsListModel

    init(model: NewsListModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        NewsListStateRenderer(
            state: model.state,
            onRetryTap: model.retryTapped,
            onRefresh: model.refreshRequested,
            onArticleTap: model.articleTapped(id:),
            onLikeTap: model.likeTapped(id:),
            onCommentsTap: model.commentsTapped(id:),
            onItemAppear: model.loadNextPageIfNeeded(currentItemID:),
            onRetryLoadNextPageTap: model.retryLoadNextPageTapped
        )
        .navigationTitle(AppStrings.text("News"))
        .background(AppTheme.backgroundBase)
        .task {
            model.appeared()
        }
        .onAppear {
            model.becameVisible()
        }
    }
}

#Preview {
    NavigationStack {
        NewsListScreen(
            model: NewsListModel(
                repository: MockNewsRepository(),
                router: NewsRouter(),
                interactionStore: ArticleInteractionStore()
            )
        )
    }
}
