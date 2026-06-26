import SwiftUI

struct NewsListStateRenderer: View {
    let state: NewsListViewState
    let onRetryTap: () -> Void
    let onRefresh: () async -> Void
    let onArticleTap: (NewsArticle.ID) -> Void
    let onLikeTap: (NewsArticle.ID) -> Void
    let onCommentsTap: (NewsArticle.ID) -> Void
    let onItemAppear: (NewsArticle.ID) -> Void
    let onRetryLoadNextPageTap: () -> Void

    var body: some View {
        switch state {
        case .idle, .loading:
            LoadingStateView(title: AppStrings.text("Loading news..."))

        case .content(let content):
            NewsListContentView(
                state: content,
                onRefresh: onRefresh,
                onArticleTap: onArticleTap,
                onLikeTap: onLikeTap,
                onCommentsTap: onCommentsTap,
                onItemAppear: onItemAppear,
                onRetryLoadNextPageTap: onRetryLoadNextPageTap
            )

        case .refreshing(let content):
            NewsListContentView(
                state: content,
                onRefresh: onRefresh,
                onArticleTap: onArticleTap,
                onLikeTap: onLikeTap,
                onCommentsTap: onCommentsTap,
                onItemAppear: onItemAppear,
                onRetryLoadNextPageTap: onRetryLoadNextPageTap
            )
            .overlay(alignment: .top) {
                ProgressView()
                    .padding(AppSpacing.md)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
            }

        case .empty(let empty):
            MessageStateView(
                title: empty.title,
                message: empty.message,
                buttonTitle: empty.retryTitle,
                onButtonTap: onRetryTap
            )

        case .error(let error):
            MessageStateView(
                title: error.title,
                message: error.message,
                buttonTitle: error.retryTitle,
                onButtonTap: onRetryTap
            )
        }
    }
}
