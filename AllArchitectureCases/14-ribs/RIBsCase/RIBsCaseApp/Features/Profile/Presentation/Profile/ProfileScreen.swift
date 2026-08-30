import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct ProfileScreen: View {
    @State private var interactor: ProfileInteractor

    init(interactor: ProfileInteractor) {
        _interactor = State(initialValue: interactor)
    }

    var body: some View {
        ProfileStateRenderer(
            state: interactor.state,
            onRetryTap: interactor.retryTapped,
            onEditTap: interactor.editTapped
        )
        .navigationTitle(AppStrings.text("Profile"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppStrings.text("Logout")) {
                    interactor.logoutTapped()
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.logoutButton)
            }
        }
        .task {
            interactor.appeared()
        }
    }
}
