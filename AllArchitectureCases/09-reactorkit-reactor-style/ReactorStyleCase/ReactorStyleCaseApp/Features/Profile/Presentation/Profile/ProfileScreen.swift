import SwiftUI

struct ProfileScreen: View {
    @State private var reactor: ProfileReactor

    init(reactor: ProfileReactor) {
        _reactor = State(initialValue: reactor)
    }

    var body: some View {
        ProfileStateRenderer(
            state: reactor.state,
            onRetryTap: reactor.retryTapped,
            onEditTap: reactor.editTapped
        )
        .navigationTitle(AppStrings.text("Profile"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppStrings.text("Logout")) {
                    reactor.logoutTapped()
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.logoutButton)
            }
        }
        .task {
            reactor.appeared()
        }
    }
}
