import SwiftUI

struct NewsListScreen: View {
    @State private var viewModel: NewsListViewModel

    init(viewModel: NewsListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NewsListStateRenderer(
            state: viewModel.state,
            onRetryTap: viewModel.retryTapped,
            onRefresh: viewModel.refreshRequested,
            onArticleTap: viewModel.articleTapped(id:),
            onLikeTap: viewModel.likeTapped(id:),
            onCommentsTap: viewModel.commentsTapped(id:),
            onItemAppear: viewModel.loadNextPageIfNeeded(currentItemID:),
            onRetryLoadNextPageTap: viewModel.retryLoadNextPageTapped
        )
        .navigationTitle(AppStrings.text("News"))
        .background(AppTheme.backgroundBase)
        .task {
            viewModel.appeared()
        }
        .onAppear {
            viewModel.becameVisible()
        }
    }
}

#Preview {
    NavigationStack {
        NewsListScreen(
            viewModel: NewsListViewModel(
                repository: MockNewsRepository(),
                router: NewsRouter(),
                interactionStore: ArticleInteractionStore()
            )
        )
    }
}
