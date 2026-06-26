import SwiftUI

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
