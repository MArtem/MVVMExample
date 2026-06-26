import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
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
