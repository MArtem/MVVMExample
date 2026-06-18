import SwiftUI

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
