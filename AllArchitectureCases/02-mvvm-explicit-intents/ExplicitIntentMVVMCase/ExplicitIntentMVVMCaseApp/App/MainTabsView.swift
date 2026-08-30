import SwiftUI

/// SwiftUI composition surface for app-level navigation state.
///
/// Ownership: reads coordinator/router state and creates feature entry views; it should not own network, persistence, or feature business behavior.
struct MainTabsView: View {
    @Bindable var coordinator: MainCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            NewsNavigationStack(
                router: coordinator.newsRouter,
                dependencies: coordinator.dependencies
            )
            .tabItem {
                Label(AppStrings.text("News"), systemImage: "newspaper")
            }
            .tag(AppTab.news)

            ProfileNavigationStack(
                router: coordinator.profileRouter,
                session: coordinator.session,
                dependencies: coordinator.dependencies,
                onLogout: {
                    coordinator.logout()
                }
            )
            .tabItem {
                Label(AppStrings.text("Profile"), systemImage: "person.crop.circle")
            }
            .tag(AppTab.profile)
        }
    }
}
