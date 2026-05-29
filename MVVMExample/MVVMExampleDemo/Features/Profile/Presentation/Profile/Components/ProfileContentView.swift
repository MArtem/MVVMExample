import SwiftUI

struct ProfileContentView: View {
    let state: ProfileContentViewState
    let onAction: (ProfileAction) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                AsyncImage(url: state.imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .empty:
                        ProgressView()
                    case .failure:
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .foregroundStyle(AppTheme.textTertiary)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .padding(.top, AppSpacing.lg)

                Text(state.displayName)
                    .font(AppTypography.title)

                Text(state.usernameText)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textSecondary)

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    ProfileInfoRow(title: "Email", value: state.emailText, icon: "envelope")
                    ProfileInfoRow(title: "Phone", value: state.phoneText, icon: "phone")
                    ProfileInfoRow(title: "Role", value: state.companyText, icon: "briefcase")
                }
                .padding(AppSpacing.md)
                .background(AppTheme.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))

                Button {
                    onAction(.editTapped)
                } label: {
                    Label("Edit profile", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
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
