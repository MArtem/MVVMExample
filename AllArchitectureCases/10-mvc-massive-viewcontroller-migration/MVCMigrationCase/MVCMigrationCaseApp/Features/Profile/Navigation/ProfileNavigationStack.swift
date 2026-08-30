import SwiftUI

/// Composes the profile navigation stack and creates screen Controllers at route boundaries.
struct ProfileNavigationStack: View {
    @Bindable var router: ProfileRouter
    let session: AuthSession
    let dependencies: AppDependencies
    let onLogout: () -> Void
    @State private var profileStore: ProfileController

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
            initialValue: ProfileController(
                session: session,
                repository: dependencies.profileRepository,
                router: router,
                onLogout: onLogout
            )
        )
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileScreen(controller: profileStore)
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .edit(let payload):
                        ProfileEditScreen(
                            controller: ProfileEditController(
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
