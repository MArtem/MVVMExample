import SwiftUI

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
