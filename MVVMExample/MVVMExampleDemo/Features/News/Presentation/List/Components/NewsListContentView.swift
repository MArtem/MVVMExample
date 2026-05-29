import SwiftUI

struct NewsListContentView: View {
    let state: NewsListContentViewState
    let onAction: (NewsListAction) -> Void

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
                    NewsCardView(state: card) { action in
                        switch action {
                        case .open:
                            onAction(.cardTapped(card.id))
                        case .like:
                            onAction(.likeTapped(card.id))
                        case .comments:
                            onAction(.commentsTapped(card.id))
                        }
                    }
                }
            }
            .padding(AppSpacing.md)
        }
        .refreshable {
            onAction(.refreshRequested)
        }
    }
}
