import SwiftUI

struct ProfileScreen: View {
    @State private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ProfileStateRenderer(
            state: viewModel.state,
            onAction: viewModel.send
        )
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Logout") {
                    viewModel.send(.logoutTapped)
                }
            }
        }
        .task {
            viewModel.send(.appeared)
        }
    }
}
