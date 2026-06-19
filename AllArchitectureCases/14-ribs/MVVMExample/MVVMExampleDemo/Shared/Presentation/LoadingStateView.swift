import SwiftUI

struct LoadingStateView: View {
    let title: String

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
