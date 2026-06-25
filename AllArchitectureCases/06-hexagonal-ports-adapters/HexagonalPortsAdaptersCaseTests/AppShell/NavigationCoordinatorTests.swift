import SwiftData
import Testing
@testable import HexagonalPortsAdaptersCase

@MainActor
@Suite("Navigation coordinator tests")
struct NavigationCoordinatorTests {
    @Test("News router opens pops and resets detail route")
    func newsRouterOpensPopsAndResetsDetailRoute() {
        let router = NewsRouter()
        let payload = NewsDetailRoutePayload(id: 7, title: "Article", thumbnailURL: nil)

        #expect(router.path.isEmpty == true)

        router.openDetail(payload)
        #expect(router.path.isEmpty == false)

        router.pop()
        #expect(router.path.isEmpty == true)

        router.openDetail(payload)
        router.reset()
        #expect(router.path.isEmpty == true)

        router.pop()
        #expect(router.path.isEmpty == true)
    }

    @Test("Profile router opens pops and resets edit route")
    func profileRouterOpensPopsAndResetsEditRoute() {
        let router = ProfileRouter()
        let payload = ProfileEditRoutePayload(
            id: 42,
            firstName: "Ada",
            lastName: "Lovelace",
            email: "ada@example.com"
        )

        #expect(router.path.isEmpty == true)

        router.openEdit(payload)
        #expect(router.path.isEmpty == false)

        router.pop()
        #expect(router.path.isEmpty == true)

        router.openEdit(payload)
        router.reset()
        #expect(router.path.isEmpty == true)

        router.pop()
        #expect(router.path.isEmpty == true)
    }

    @Test("Main coordinator logout resets feature routes before delegating logout")
    func mainCoordinatorLogoutResetsFeatureRoutesBeforeDelegatingLogout() throws {
        let container = try makeInMemoryModelContainer()
        let context = ModelContext(container)
        let dependencies = makeCoordinatorDependencies(
            context: context,
            modelContainer: container,
            sessionStore: InMemorySessionStore<AuthSession>()
        )
        var observedNewsPathWasEmpty = false
        var observedProfilePathWasEmpty = false
        var logoutCount = 0
        var coordinator: MainCoordinator!
        coordinator = MainCoordinator(
            session: makeNavigationSession(),
            dependencies: dependencies,
            onLogout: {
                observedNewsPathWasEmpty = coordinator.newsRouter.path.isEmpty
                observedProfilePathWasEmpty = coordinator.profileRouter.path.isEmpty
                logoutCount += 1
            }
        )

        coordinator.newsRouter.openDetail(NewsDetailRoutePayload(id: 7, title: "Article", thumbnailURL: nil))
        coordinator.profileRouter.openEdit(ProfileEditRoutePayload(
            id: 42,
            firstName: "Ada",
            lastName: "Lovelace",
            email: "ada@example.com"
        ))

        #expect(coordinator.newsRouter.path.isEmpty == false)
        #expect(coordinator.profileRouter.path.isEmpty == false)

        coordinator.logout()

        #expect(observedNewsPathWasEmpty == true)
        #expect(observedProfilePathWasEmpty == true)
        #expect(coordinator.newsRouter.path.isEmpty == true)
        #expect(coordinator.profileRouter.path.isEmpty == true)
        #expect(logoutCount == 1)
    }
}

private func makeNavigationSession() -> AuthSession {
    AuthSession(
        accessToken: "navigation-access-token-not-a-secret",
        refreshToken: "navigation-refresh-token-not-a-secret",
        user: AppUser(
            id: 42,
            username: "ada",
            email: "ada@example.com",
            firstName: "Ada",
            lastName: "Lovelace",
            imageURL: nil
        )
    )
}
