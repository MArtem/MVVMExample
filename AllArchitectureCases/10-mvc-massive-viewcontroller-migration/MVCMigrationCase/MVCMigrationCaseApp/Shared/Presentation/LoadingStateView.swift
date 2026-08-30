import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
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
