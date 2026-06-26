import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct ProfileScreen: View {
    @State private var controller: ProfileController

    init(controller: ProfileController) {
        _controller = State(initialValue: controller)
    }

    var body: some View {
        ProfileStateRenderer(
            state: controller.state,
            onRetryTap: controller.retryTapped,
            onEditTap: controller.editTapped
        )
        .navigationTitle(AppStrings.text("Profile"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppStrings.text("Logout")) {
                    controller.logoutTapped()
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.logoutButton)
            }
        }
        .task {
            controller.appeared()
        }
    }
}
