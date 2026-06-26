import SwiftUI

/// Composes the profile navigation stack and creates screen Interactors at route boundaries.
struct ProfileNavigationStack: View {
    @Bindable var router: ProfileRouter
    let session: AuthSession
    let dependencies: AppDependencies
    let onLogout: () -> Void
    @State private var profileInteractor: ProfileInteractor

    init(
        router: ProfileRouter,
        session: AuthSession,
        dependencies: AppDependencies,
        onLogout: @escaping () -> Void
    ) {
        self.router = router
        self.session = session
        self.dependencies = dependencies
        self.onLogout = onLogout
        _profileInteractor = State(
            initialValue: ProfileBuilder.makeInteractor(
                component: Self.makeComponent(
                    session: session,
                    dependencies: dependencies,
                    router: router,
                    onLogout: onLogout
                )
            )
        )
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileScreen(interactor: profileInteractor)
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .edit(let payload):
                        ProfileEditBuilder(
                            component: Self.makeComponent(
                                session: session,
                                dependencies: dependencies,
                                router: router,
                                onLogout: onLogout
                            ),
                            payload: payload,
                            onSaveSuccess: profileInteractor.profileUpdated
                        ).build()
                    }
                }
        }
    }
}


private extension ProfileNavigationStack {
    static func makeComponent(
        session: AuthSession,
        dependencies: AppDependencies,
        router: ProfileRouter,
        onLogout: @escaping () -> Void
    ) -> ProfileComponent {
        ProfileComponent(
            session: session,
            repository: dependencies.profileRepository,
            router: router,
            onLogout: onLogout
        )
    }
}

/// Profile RIB component for the authenticated profile subtree.
struct ProfileComponent {
    let session: AuthSession
    let repository: ProfileRepository
    let router: ProfileRouter
    let onLogout: () -> Void
}

/// Builder for the profile root RIB.
struct ProfileBuilder {
    @MainActor
    static func makeInteractor(component: ProfileComponent) -> ProfileInteractor {
        ProfileInteractor(
            session: component.session,
            repository: component.repository,
            router: component.router,
            onLogout: component.onLogout
        )
    }
}

/// Builder for the profile-edit child RIB.
struct ProfileEditBuilder {
    let component: ProfileComponent
    let payload: ProfileEditRoutePayload
    let onSaveSuccess: (UserProfile) -> Void

    @MainActor
    func build() -> ProfileEditScreen {
        ProfileEditScreen(
            interactor: ProfileEditInteractor(
                payload: payload,
                repository: component.repository,
                router: component.router,
                onSaveSuccess: onSaveSuccess
            )
        )
    }
}
