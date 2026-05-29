import Foundation
import Observation

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
