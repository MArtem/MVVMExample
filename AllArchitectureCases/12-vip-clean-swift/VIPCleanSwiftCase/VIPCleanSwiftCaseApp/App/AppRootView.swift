import SwiftUI

/// SwiftUI composition surface for app-level navigation state.
///
/// Ownership: reads coordinator/router state and creates feature entry views; it should not own network, persistence, or feature business behavior.
struct AppRootView: View {
    @Bindable var coordinator: AppRootCoordinator

    var body: some View {
        switch coordinator.scene {
        case .login:
            LoginSceneBuilder(
                dependencies: coordinator.dependencies,
                onLoginSuccess: { session in
                    coordinator.handleLoginSuccess(session)
                }
            ).build()

        case .main:
            if let mainCoordinator = coordinator.mainCoordinator {
                MainTabsView(coordinator: mainCoordinator)
            } else {
                ProgressView()
            }
        }
    }
}


/// Clean Swift scene builder for the login scene composition boundary.
struct LoginSceneBuilder {
    let dependencies: AppDependencies
    let onLoginSuccess: (AuthSession) -> Void

    @MainActor
    func build() -> LoginScreen {
        LoginScreen(
            interactor: LoginInteractor(
                repository: dependencies.authRepository,
                demoCredentials: dependencies.demoCredentials,
                onLoginSuccess: onLoginSuccess
            )
        )
    }
}
