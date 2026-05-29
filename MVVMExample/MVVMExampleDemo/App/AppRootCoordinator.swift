import Foundation
import Observation

@MainActor
@Observable
final class AppRootCoordinator {
    enum Scene: Equatable {
        case login
        case main
    }

    private(set) var scene: Scene = .login
    private(set) var mainCoordinator: MainCoordinator?

    let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func handleLoginSuccess(_ session: AuthSession) {
        mainCoordinator = MainCoordinator(
            session: session,
            dependencies: dependencies,
            onLogout: { [weak self] in
                self?.logout()
            }
        )
        scene = .main
    }

    func logout() {
        mainCoordinator = nil
        scene = .login
    }
}
