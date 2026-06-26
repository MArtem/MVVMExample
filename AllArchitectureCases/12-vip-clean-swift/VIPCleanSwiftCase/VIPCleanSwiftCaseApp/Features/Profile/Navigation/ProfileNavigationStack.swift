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
            initialValue: ProfileInteractor(
                session: session,
                repository: dependencies.profileRepository,
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
                        ProfileEditScreen(
                            interactor: ProfileEditInteractor(
                                payload: payload,
                                repository: dependencies.profileRepository,
                                router: router,
                                onSaveSuccess: profileInteractor.profileUpdated
                            )
                        )
                    }
                }
        }
    }
}
