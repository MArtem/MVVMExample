import SwiftUI

struct ProfileContentView: View {
    let state: ProfileContentViewState
    let onEditTap: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                AsyncImageView(url: state.imageURL, width: 120, height: 120)
                    .clipShape(Circle())
                .padding(.top, AppSpacing.lg)

                Text(state.displayName)
                    .font(AppTypography.title)

                Text(state.usernameText)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textSecondary)

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    ProfileInfoRow(title: AppStrings.text("Email"), value: state.emailText, icon: "envelope")
                    ProfileInfoRow(title: AppStrings.text("Phone"), value: state.phoneText, icon: "phone")
                    ProfileInfoRow(title: AppStrings.text("Role"), value: state.companyText, icon: "briefcase")
                }
                .padding(AppSpacing.md)
                .appAdaptiveCardSurface()

                Button(action: onEditTap) {
                    Label(AppStrings.text("Edit profile"), systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(AppAccessibilityID.Profile.editButton)
            }
            .padding(AppSpacing.md)
        }
        .background(AppTheme.backgroundBase)
    }
}

private struct ProfileInfoRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.actionPrimary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.textTertiary)

                Text(value)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textPrimary)
            }

            Spacer()
        }
    }
}
