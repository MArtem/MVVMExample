import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct ProfileScreen: View {
    @State private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ProfileStateRenderer(
            state: viewModel.state,
            onRetryTap: viewModel.retryTapped,
            onEditTap: viewModel.editTapped
        )
        .navigationTitle(AppStrings.text("Profile"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppStrings.text("Logout")) {
                    viewModel.logoutTapped()
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.logoutButton)
            }
        }
        .task {
            viewModel.appeared()
        }
    }
}
