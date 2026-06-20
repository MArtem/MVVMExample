import SwiftUI

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
