import SwiftUI

struct NewsListContentView: View {
    let state: NewsListContentViewState
    let onRefresh: () -> Void
    let onArticleTap: (NewsArticle.ID) -> Void
    let onLikeTap: (NewsArticle.ID) -> Void
    let onCommentsTap: (NewsArticle.ID) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                if let banner = state.banner {
                    Text(banner)
                        .font(AppTypography.bodySmall)
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppSpacing.md)
                        .background(AppTheme.surfacePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
                }

                ForEach(state.cards) { card in
                    NewsCardView(
                        state: card,
                        onOpen: { onArticleTap(card.id) },
                        onLike: { onLikeTap(card.id) },
                        onComments: { onCommentsTap(card.id) }
                    )
                }
            }
            .padding(AppSpacing.md)
        }
        .refreshable {
            onRefresh()
        }
    }
}
