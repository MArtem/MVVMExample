import SwiftUI

struct ProfileScreen: View {
    @State private var store: ProfilePresenter

    init(store: ProfilePresenter) {
        _store = State(initialValue: store)
    }

    var body: some View {
        ProfileStateRenderer(
            state: store.state,
            onRetryTap: store.retryTapped,
            onEditTap: store.editTapped
        )
        .navigationTitle(AppStrings.text("Profile"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppStrings.text("Logout")) {
                    store.logoutTapped()
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.logoutButton)
            }
        }
        .task {
            store.appeared()
        }
    }
}
