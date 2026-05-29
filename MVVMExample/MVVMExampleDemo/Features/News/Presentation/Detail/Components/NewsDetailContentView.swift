import SwiftUI

struct NewsDetailContentView: View {
    let state: NewsDetailContentViewState
    let onAction: (NewsDetailAction) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                AsyncImageView(url: state.imageURL, height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Text(state.sourceText)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppTheme.actionPrimary)

                        Spacer()

                        Text(state.categoryText)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Text(state.title)
                        .font(AppTypography.title)
                        .foregroundStyle(AppTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(state.excerpt)
                        .font(AppTypography.body)
                        .foregroundStyle(AppTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(AppSpacing.md)
                .background(AppTheme.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))

                HStack {
                    Label(state.ratingText, systemImage: "star.fill")
                    Spacer()
                    Label(state.likesText, systemImage: "hand.thumbsup")
                    Spacer()
                    Label(state.commentsText, systemImage: "bubble.left")
                }
                .font(AppTypography.bodySmall)
                .foregroundStyle(AppTheme.textSecondary)
                .padding(AppSpacing.md)
                .background(AppTheme.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))

                Button {
                    onAction(.favoriteTapped)
                } label: {
                    Label(
                        state.isFavorite ? "Remove from favorites" : "Add to favorites",
                        systemImage: state.isFavorite ? "heart.fill" : "heart"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(AppSpacing.md)
        }
        .background(AppTheme.backgroundBase)
    }
}
