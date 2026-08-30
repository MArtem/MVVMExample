import SwiftUI

/// Scrollable news-list content surface.
///
/// Responsibilities:
/// - keeps `ForEach` directly inside `LazyVStack` for lazy row creation;
/// - forwards row visibility to the Store for pagination;
/// - awaits refresh work so system refresh UI reflects actual loading.
struct NewsListContentView: View {
    let state: NewsListContentViewState
    let onRefresh: () async -> Void
    let onArticleTap: (NewsArticle.ID) -> Void
    let onLikeTap: (NewsArticle.ID) -> Void
    let onCommentsTap: (NewsArticle.ID) -> Void
    let onItemAppear: (NewsArticle.ID) -> Void
    let onRetryLoadNextPageTap: () -> Void

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
                    .equatable()
                    .onAppear {
                        onItemAppear(card.id)
                    }
                }

                paginationFooter
            }
            .padding(AppSpacing.md)
        }
        .accessibilityIdentifier(AppAccessibilityID.News.list)
        .refreshable {
            await onRefresh()
        }
    }
    @ViewBuilder
    private var paginationFooter: some View {
        switch state.pagination.status {
        case .idle:
            EmptyView()
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.md)
        case .error(let message, let retryTitle):
            VStack(spacing: AppSpacing.sm) {
                Text(message)
                    .font(AppTypography.bodySmall)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)

                Button(retryTitle, action: onRetryLoadNextPageTap)
                    .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.md)
        case .endReached(let message):
            Text(message)
                .font(AppTypography.bodySmall)
                .foregroundStyle(AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.md)
        }
    }

}
