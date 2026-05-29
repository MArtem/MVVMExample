import SwiftUI

struct NewsListStateRenderer: View {
    let state: NewsListViewState
    let onAction: (NewsListAction) -> Void

    var body: some View {
        switch state {
        case .idle, .loading:
            LoadingStateView(title: "Loading news...")

        case .content(let content):
            NewsListContentView(state: content, onAction: onAction)

        case .refreshing(let content):
            NewsListContentView(state: content, onAction: onAction)
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
                onButtonTap: { onAction(.retryTapped) }
            )

        case .error(let error):
            MessageStateView(
                title: error.title,
                message: error.message,
                buttonTitle: error.retryTitle,
                onButtonTap: { onAction(.retryTapped) }
            )
        }
    }
}
