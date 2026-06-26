import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct ProfileStateRenderer: View {
    let state: ProfileViewState
    let onRetryTap: () -> Void
    let onEditTap: () -> Void

    var body: some View {
        switch state {
        case .loading:
            LoadingStateView(title: AppStrings.text("Loading profile..."))

        case .content(let content):
            ProfileContentView(
                state: content,
                onEditTap: onEditTap
            )

        case .error(let error):
            MessageStateView(
                title: error.title,
                message: error.message,
                buttonTitle: error.retryTitle,
                onButtonTap: onRetryTap
            )
        }
    }
}
