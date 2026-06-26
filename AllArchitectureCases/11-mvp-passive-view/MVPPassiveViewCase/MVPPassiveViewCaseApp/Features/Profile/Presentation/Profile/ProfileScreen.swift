import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct ProfileScreen: View {
    @State private var presenter: ProfilePresenter

    init(presenter: ProfilePresenter) {
        _presenter = State(initialValue: presenter)
    }

    var body: some View {
        ProfileStateRenderer(
            state: presenter.state,
            onRetryTap: presenter.retryTapped,
            onEditTap: presenter.editTapped
        )
        .navigationTitle(AppStrings.text("Profile"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppStrings.text("Logout")) {
                    presenter.logoutTapped()
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.logoutButton)
            }
        }
        .task {
            presenter.appeared()
        }
    }
}
