import Foundation
import Observation

/// Coordinator for authenticated main-tab navigation.
///
/// Responsibilities:
/// - owns tab selection and feature routers;
/// - resets feature navigation before delegating logout to the app root owner.
@MainActor
@Observable
final class MainCoordinator {
    var selectedTab: AppTab = .news

    let newsRouter = NewsRouter()
    let profileRouter = ProfileRouter()

    let session: AuthSession
    let dependencies: AppDependencies
    private let onLogout: () -> Void

    init(
        session: AuthSession,
        dependencies: AppDependencies,
        onLogout: @escaping () -> Void
    ) {
        self.session = session
        self.dependencies = dependencies
        self.onLogout = onLogout
    }

    func logout() {
        newsRouter.reset()
        profileRouter.reset()
        onLogout()
    }
}
