import SwiftUI

/// Composes the news navigation stack and creates screen Stores at route boundaries.
struct NewsNavigationStack: View {
    @Bindable var router: NewsRouter
    let dependencies: AppDependencies

    var body: some View {
        NavigationStack(path: $router.path) {
            NewsListScreen(
                store: NewsListStore(
                    repository: dependencies.newsRepository,
                    router: router,
                    interactionStore: dependencies.articleInteractionStore
                )
            )
            .navigationDestination(for: NewsRoute.self) { route in
                switch route {
                case .detail(let payload):
                    NewsDetailScreen(
                        store: NewsDetailStore(
                            payload: payload,
                            repository: dependencies.newsRepository,
                            interactionStore: dependencies.articleInteractionStore
                        )
                    )
                }
            }
        }
    }
}
