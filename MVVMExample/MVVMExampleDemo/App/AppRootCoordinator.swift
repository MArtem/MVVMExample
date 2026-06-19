import Foundation
import Observation

/// App-level coordinator that owns the auth gate and main-app scene transition.
///
/// Ownership:
/// Created by the app root view for the process lifetime.
///
/// Side effects:
/// Saves and clears the current session through `SessionStore` and recreates child coordinators on auth transitions.
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
            dependencies.articleInteractionStore.activateUser(id: session.user.id)
            dependencies.pendingMutationSyncService.syncPendingMutations(for: session.user.id)
            installMainCoordinator(for: session)
            scene = .main
        }
    }

    /// Completes the login transition by storing the session and installing main navigation.
    func handleLoginSuccess(_ session: AuthSession) {
        dependencies.sessionStore.save(session)
        dependencies.articleInteractionStore.activateUser(id: session.user.id)
        dependencies.pendingMutationSyncService.syncPendingMutations(for: session.user.id)
        installMainCoordinator(for: session)
        scene = .main
    }

    func logout() {
        dependencies.pendingMutationSyncService.cancel()
        dependencies.sessionStore.clear()
        dependencies.articleInteractionStore.clearActiveUser()
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
