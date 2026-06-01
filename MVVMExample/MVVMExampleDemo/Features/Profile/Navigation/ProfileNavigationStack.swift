import SwiftUI

/// Composes the profile navigation stack and creates screen ViewModels at route boundaries.
struct ProfileNavigationStack: View {
    @Bindable var router: ProfileRouter
    let session: AuthSession
    let dependencies: AppDependencies
    let onLogout: () -> Void

    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileScreen(
                viewModel: ProfileViewModel(
                    session: session,
                    repository: dependencies.profileRepository,
                    router: router,
                    onLogout: onLogout
                )
            )
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .edit(let payload):
                    ProfileEditScreen(
                        viewModel: ProfileEditViewModel(
                            payload: payload,
                            repository: dependencies.profileRepository,
                            router: router
                        )
                    )
                }
            }
        }
    }
}
