import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct MessageStateView: View {
    let title: String
    let message: String
    let buttonTitle: String?
    let onButtonTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppTheme.textPrimary)

            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let buttonTitle, let onButtonTap {
                Button(buttonTitle, action: onButtonTap)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, AppSpacing.sm)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
    }
}
