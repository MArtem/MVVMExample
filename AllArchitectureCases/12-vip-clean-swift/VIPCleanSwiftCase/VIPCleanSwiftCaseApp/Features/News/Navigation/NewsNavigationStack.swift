import SwiftUI

/// Composes the news navigation stack and creates screen Interactors at route boundaries.
struct NewsNavigationStack: View {
    @Bindable var router: NewsRouter
    let dependencies: AppDependencies

    var body: some View {
        NavigationStack(path: $router.path) {
            NewsListSceneBuilder(dependencies: dependencies, router: router).build()
            .navigationDestination(for: NewsRoute.self) { route in
                switch route {
                case .detail(let payload):
                    NewsDetailSceneBuilder(
                        dependencies: dependencies,
                        payload: payload
                    ).build()
                }
            }
        }
    }
}


/// Clean Swift scene builder for the news-list scene composition boundary.
struct NewsListSceneBuilder {
    let dependencies: AppDependencies
    let router: NewsRouter

    @MainActor
    func build() -> NewsListScreen {
        NewsListScreen(
            interactor: NewsListInteractor(
                repository: dependencies.newsRepository,
                router: router,
                interactionStore: dependencies.articleInteractionStore
            )
        )
    }
}

/// Clean Swift scene builder for the news-detail scene composition boundary.
struct NewsDetailSceneBuilder {
    let dependencies: AppDependencies
    let payload: NewsDetailRoutePayload

    @MainActor
    func build() -> NewsDetailScreen {
        NewsDetailScreen(
            interactor: NewsDetailInteractor(
                payload: payload,
                repository: dependencies.newsRepository,
                interactionStore: dependencies.articleInteractionStore
            )
        )
    }
}
