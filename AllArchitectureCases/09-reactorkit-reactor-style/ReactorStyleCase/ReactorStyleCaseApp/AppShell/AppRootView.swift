import SwiftUI

struct AppRootView: View {
    @Bindable var coordinator: AppRootCoordinator

    var body: some View {
        switch coordinator.scene {
        case .login:
            LoginScreen(
                store: LoginReactor(
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
