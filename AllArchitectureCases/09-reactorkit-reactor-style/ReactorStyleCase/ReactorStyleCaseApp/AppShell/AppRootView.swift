import SwiftUI

/// SwiftUI composition surface for app-level navigation state.
///
/// Ownership: reads coordinator/router state and creates feature entry views; it should not own network, persistence, or feature business behavior.
struct AppRootView: View {
    @Bindable var coordinator: AppRootCoordinator

    var body: some View {
        switch coordinator.scene {
        case .login:
            LoginScreen(
                reactor: LoginReactor(
                    repository: coordinator.dependencies.authRepository,
                    demoCredentials: coordinator.dependencies.demoCredentials,
                    onLoginSuccess: { session in
                        coordinator.handleLoginSuccess(session)
                    }
                )
            )

        case .main:
            if let mainCoordinator = coordinator.mainCoordinator {
                MainTabsView(coordinator: mainCoordinator)
            } else {
                ProgressView()
            }
        }
    }
}
