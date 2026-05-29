import SwiftUI

struct NewsDetailStateRenderer: View {
    let state: NewsDetailViewState
    let onAction: (NewsDetailAction) -> Void

    var body: some View {
        switch state {
        case .loading(let placeholder):
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    AsyncImageView(url: placeholder.thumbnailURL, height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))

                    Text(placeholder.title)
                        .font(AppTypography.title)

                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
                .padding(AppSpacing.md)
            }
            .background(AppTheme.backgroundBase)

        case .content(let content):
            NewsDetailContentView(state: content, onAction: onAction)

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
