import SwiftUI

/// SwiftUI composition surface for app-level navigation state.
///
/// Ownership: reads coordinator/router state and creates feature entry views; it should not own network, persistence, or feature business behavior.
struct AppRootView: View {
    @Bindable var coordinator: AppRootCoordinator

    var body: some View {
        switch coordinator.scene {
        case .login:
            LoginBuilder(
                component: AppComponent(dependencies: coordinator.dependencies),
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


/// Root RIB component that scopes app-level dependencies without becoming a global singleton.
struct AppComponent {
    let dependencies: AppDependencies
}

/// Builder for the login RIB.
struct LoginBuilder {
    let component: AppComponent
    let onLoginSuccess: (AuthSession) -> Void

    @MainActor
    func build() -> LoginScreen {
        LoginScreen(
            interactor: LoginInteractor(
                repository: component.dependencies.authRepository,
                demoCredentials: component.dependencies.demoCredentials,
                onLoginSuccess: onLoginSuccess
            )
        )
    }
}
