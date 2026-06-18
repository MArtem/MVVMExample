import SwiftUI

struct NewsDetailStateRenderer: View {
    let state: NewsDetailViewState
    let onRetryTap: () -> Void
    let onFavoriteTap: () -> Void

    var body: some View {
        switch state {
        case .loading(let placeholder):
            VStack(spacing: AppSpacing.md) {
                AsyncImageView(url: placeholder.thumbnailURL, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
                LoadingStateView(title: AppStrings.text("Loading details..."))
            }
            .padding(AppSpacing.md)

        case .content(let content):
            NewsDetailContentView(
                state: content,
                onFavoriteTap: onFavoriteTap
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
