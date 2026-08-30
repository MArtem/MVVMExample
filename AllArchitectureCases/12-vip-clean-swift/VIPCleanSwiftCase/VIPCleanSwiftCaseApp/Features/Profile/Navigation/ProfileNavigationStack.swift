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
            initialValue: ProfileSceneBuilder.makeInteractor(
                session: session,
                dependencies: dependencies,
                router: router,
                onLogout: onLogout
            )
        )
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileScreen(interactor: profileInteractor)
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .edit(let payload):
                        ProfileEditSceneBuilder(
                            dependencies: dependencies,
                            router: router,
                            payload: payload,
                            onSaveSuccess: profileInteractor.profileUpdated
                        ).build()
                    }
                }
        }
    }
}


/// Clean Swift scene builder for the profile scene composition boundary.
struct ProfileSceneBuilder {
    @MainActor
    static func makeInteractor(
        session: AuthSession,
        dependencies: AppDependencies,
        router: ProfileRouter,
        onLogout: @escaping () -> Void
    ) -> ProfileInteractor {
        ProfileInteractor(
            session: session,
            repository: dependencies.profileRepository,
            router: router,
            onLogout: onLogout
        )
    }
}

/// Clean Swift scene builder for the profile-edit scene composition boundary.
struct ProfileEditSceneBuilder {
    let dependencies: AppDependencies
    let router: ProfileRouter
    let payload: ProfileEditRoutePayload
    let onSaveSuccess: (UserProfile) -> Void

    @MainActor
    func build() -> ProfileEditScreen {
        ProfileEditScreen(
            interactor: ProfileEditInteractor(
                payload: payload,
                repository: dependencies.profileRepository,
                router: router,
                onSaveSuccess: onSaveSuccess
            )
        )
    }
}
