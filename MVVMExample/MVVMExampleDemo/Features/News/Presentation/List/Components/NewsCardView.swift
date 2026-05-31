import SwiftUI
import AppLocalization

struct NewsCardView: View, Equatable {
    let state: NewsCardViewState
    let onOpen: () -> Void
    let onLike: () -> Void
    let onComments: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: 0) {
                    AsyncImageView(url: state.thumbnailURL, height: 190)

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(state.sourceDisplayText)
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
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(state.accessibilityLabel)
            .accessibilityHint(AppStrings.text("Opens article details"))

            Divider()

            HStack(spacing: AppSpacing.lg) {
                Button(action: onLike) {
                    Label(state.likesText, systemImage: state.likeIconName)
                        .font(AppTypography.bodySmall)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(state.likeAccessibilityLabel)

                Button(action: onComments) {
                    Label(state.commentsText, systemImage: "bubble.left")
                        .font(AppTypography.bodySmall)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(state.commentsAccessibilityLabel)

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
    }

    static func == (lhs: NewsCardView, rhs: NewsCardView) -> Bool {
        lhs.state == rhs.state
    }
}
