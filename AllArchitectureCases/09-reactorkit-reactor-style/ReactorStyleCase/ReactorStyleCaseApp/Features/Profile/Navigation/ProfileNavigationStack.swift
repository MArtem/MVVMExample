import SwiftUI

/// Composes the profile navigation stack and creates screen Reactors at route boundaries.
struct ProfileNavigationStack: View {
    @Bindable var router: ProfileRouter
    let session: AuthSession
    let dependencies: AppDependencies
    let onLogout: () -> Void
    @State private var profileStore: ProfileReactor

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
        _profileStore = State(
            initialValue: ProfileReactor(
                session: session,
                repository: dependencies.profileRepository,
                router: router,
                onLogout: onLogout
            )
        )
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileScreen(reactor: profileStore)
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .edit(let payload):
                        ProfileEditScreen(
                            reactor: ProfileEditReactor(
                                payload: payload,
                                repository: dependencies.profileRepository,
                                router: router,
                                onSaveSuccess: profileStore.profileUpdated
                            )
                        )
                    }
                }
        }
    }
}
