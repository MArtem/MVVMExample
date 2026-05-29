import SwiftUI

struct NewsCardView: View {
    let state: NewsCardViewState
    let onAction: (NewsCardAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImageView(url: state.thumbnailURL, height: 190)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(state.sourceText.uppercased())
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.actionPrimary)

                Text(state.title)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(state.excerpt)
                    .font(AppTypography.bodySmall)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                Text(state.publishedAtText)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            .padding(AppSpacing.md)

            Divider()

            HStack(spacing: AppSpacing.lg) {
                Button {
                    onAction(.like)
                } label: {
                    Label(state.likesText, systemImage: likeIcon)
                        .font(AppTypography.bodySmall)
                }
                .buttonStyle(.plain)

                Button {
                    onAction(.comments)
                } label: {
                    Label(state.commentsText, systemImage: "bubble.left")
                        .font(AppTypography.bodySmall)
                }
                .buttonStyle(.plain)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            .padding(AppSpacing.md)
        }
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppTheme.divider.opacity(0.35), lineWidth: 1)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onAction(.open)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(state.accessibilityLabel)
    }

    private var likeIcon: String {
        switch state.likeState {
        case .liked:
            return "hand.thumbsup.fill"
        case .notLiked, .failed:
            return "hand.thumbsup"
        case .updating:
            return "clock"
        }
    }
}
