import SwiftUI

struct ProfileStateRenderer: View {
    let state: ProfileViewState
    let onAction: (ProfileAction) -> Void

    var body: some View {
        switch state {
        case .loading:
            LoadingStateView(title: "Loading profile...")

        case .content(let content):
            ProfileContentView(state: content, onAction: onAction)

        case .error(let error):
            MessageStateView(
                title: error.title,
                message: error.message,
                buttonTitle: error.retryTitle,
                onButtonTap: { onAction(.retryTapped) }
            )
        }
    }
}
