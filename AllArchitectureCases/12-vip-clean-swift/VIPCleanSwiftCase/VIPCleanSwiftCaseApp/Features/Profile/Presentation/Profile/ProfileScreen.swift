import SwiftUI

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
