import SwiftUI

struct MainTabsView: View {
    @Bindable var coordinator: MainCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            NewsNavigationStack(
                router: coordinator.newsRouter,
                dependencies: coordinator.dependencies
            )
            .tabItem {
                Label("News", systemImage: "newspaper")
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
                Label("Profile", systemImage: "person.crop.circle")
            }
            .tag(AppTab.profile)
        }
    }
}
