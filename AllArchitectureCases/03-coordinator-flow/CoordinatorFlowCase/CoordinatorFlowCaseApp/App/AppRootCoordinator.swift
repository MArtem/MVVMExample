import Foundation
import Observation

/// App-level coordinator that owns the auth gate and main-app scene transition.
///
/// Ownership:
/// Created by the app root view for the process lifetime.
///
/// Side effects:
/// Delegates session persistence and sync lifecycle work to `AppSessionLifecycleController`; this coordinator owns only scene transitions and child coordinator installation.
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
    private let sessionLifecycle: AppSessionLifecycleController

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        self.sessionLifecycle = AppSessionLifecycleController(dependencies: dependencies)
        if let session = sessionLifecycle.restoreSessionForLaunch() {
            installMainCoordinator(for: session)
            scene = .main
        }
    }

    /// Completes the login transition by asking the app lifecycle owner to persist/activate the session, then installing main navigation.
    func handleLoginSuccess(_ session: AuthSession) {
        sessionLifecycle.activateLoggedInSession(session)
        installMainCoordinator(for: session)
        scene = .main
    }

    func logout() {
        sessionLifecycle.endCurrentSession()
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


/// Owns app-session side effects that should not live in navigation coordinators.
///
/// Responsibilities:
/// - restores persisted auth session during cold launch;
/// - activates per-user local interaction state;
/// - starts/cancels pending mutation replay;
/// - saves and clears durable auth session data.
@MainActor
final class AppSessionLifecycleController {
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func restoreSessionForLaunch() -> AuthSession? {
        guard let session = dependencies.sessionStore.currentSession else { return nil }
        activateLocalState(for: session)
        return session
    }

    func activateLoggedInSession(_ session: AuthSession) {
        dependencies.sessionStore.save(session)
        activateLocalState(for: session)
    }

    func endCurrentSession() {
        dependencies.pendingMutationSyncService.cancel()
        dependencies.sessionStore.clear()
        dependencies.articleInteractionStore.clearActiveUser()
    }

    private func activateLocalState(for session: AuthSession) {
        dependencies.articleInteractionStore.activateUser(id: session.user.id)
        dependencies.pendingMutationSyncService.syncPendingMutations(for: session.user.id)
    }
}
