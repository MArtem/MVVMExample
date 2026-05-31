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
        if let session = dependencies.sessionStore.currentSession {
            installMainCoordinator(for: session)
            scene = .main
        }
    }

    func handleLoginSuccess(_ session: AuthSession) {
        dependencies.sessionStore.save(session)
        installMainCoordinator(for: session)
        scene = .main
    }

    func logout() {
        dependencies.sessionStore.clear()
        mainCoordinator = nil
        scene = .login
    }

    private func installMainCoordinator(for session: AuthSession) {
        mainCoordinator = MainCoordinator(
            session: session,
            dependencies: dependencies,
            onLogout: { [weak self] in
                self?.logout()
            }
        )
    }
}
