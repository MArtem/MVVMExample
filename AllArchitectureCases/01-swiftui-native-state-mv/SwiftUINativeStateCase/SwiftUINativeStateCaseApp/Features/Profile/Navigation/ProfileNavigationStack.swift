import SwiftUI

/// Composes the profile navigation stack and creates screen Models at route boundaries.
struct ProfileNavigationStack: View {
    @Bindable var router: ProfileRouter
    let session: AuthSession
    let dependencies: AppDependencies
    let onLogout: () -> Void
    @State private var profileModel: ProfileModel

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
        _profileModel = State(
            initialValue: ProfileModel(
                session: session,
                repository: dependencies.profileRepository,
                router: router,
                onLogout: onLogout
            )
        )
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileScreen(model: profileModel)
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .edit(let payload):
                        ProfileEditScreen(
                            model: ProfileEditModel(
                                payload: payload,
                                repository: dependencies.profileRepository,
                                router: router,
                                onSaveSuccess: profileModel.profileUpdated
                            )
                        )
                    }
                }
        }
    }
}
