import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct ProfileScreen: View {
    @State private var model: ProfileModel

    init(model: ProfileModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        ProfileStateRenderer(
            state: model.state,
            onRetryTap: model.retryTapped,
            onEditTap: model.editTapped
        )
        .navigationTitle(AppStrings.text("Profile"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppStrings.text("Logout")) {
                    model.logoutTapped()
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.logoutButton)
            }
        }
        .task {
            model.appeared()
        }
    }
}
