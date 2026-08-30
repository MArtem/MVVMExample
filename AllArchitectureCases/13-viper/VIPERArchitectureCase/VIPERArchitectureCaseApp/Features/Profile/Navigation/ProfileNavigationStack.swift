import SwiftUI

/// Composes the profile navigation stack and creates screen Presenters at route boundaries.
struct ProfileNavigationStack: View {
    @Bindable var router: ProfileRouter
    let session: AuthSession
    let dependencies: AppDependencies
    let onLogout: () -> Void
    @State private var profilePresenter: ProfilePresenter

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
        _profilePresenter = State(
            initialValue: ProfileModuleBuilder.makePresenter(
                session: session,
                repository: dependencies.profileRepository,
                router: router,
                onLogout: onLogout
            )
        )
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileScreen(presenter: profilePresenter)
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .edit(let payload):
                        ProfileEditModuleBuilder.build(
                            payload: payload,
                            repository: dependencies.profileRepository,
                            router: router,
                            onSaveSuccess: profilePresenter.profileUpdated
                        )
                    }
                }
        }
    }
}


/// VIPER Builder for the profile module.
@MainActor
struct ProfileModuleBuilder {
    static func makePresenter(
        session: AuthSession,
        repository: ProfileRepository,
        router: ProfileRouter,
        onLogout: @escaping () -> Void
    ) -> ProfilePresenter {
        ProfilePresenter(
            interactor: ProfileInteractor(session: session, repository: repository),
            router: router,
            onLogout: onLogout
        )
    }
}

/// VIPER Builder for the profile-edit module.
@MainActor
struct ProfileEditModuleBuilder {
    static func build(
        payload: ProfileEditRoutePayload,
        repository: ProfileRepository,
        router: ProfileRouter,
        onSaveSuccess: @escaping (UserProfile) -> Void
    ) -> ProfileEditScreen {
        ProfileEditScreen(
            presenter: ProfileEditPresenter(
                payload: payload,
                interactor: ProfileEditInteractor(repository: repository),
                router: router,
                onSaveSuccess: onSaveSuccess
            )
        )
    }
}
