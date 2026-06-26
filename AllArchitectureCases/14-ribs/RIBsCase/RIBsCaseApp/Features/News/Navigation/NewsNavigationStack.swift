import SwiftUI

/// Composes the news navigation stack and creates screen Interactors at route boundaries.
struct NewsNavigationStack: View {
    @Bindable var router: NewsRouter
    let dependencies: AppDependencies

    var body: some View {
        NavigationStack(path: $router.path) {
            NewsListBuilder(component: NewsComponent(dependencies: dependencies, router: router)).build()
            .navigationDestination(for: NewsRoute.self) { route in
                switch route {
                case .detail(let payload):
                    NewsDetailBuilder(component: NewsComponent(dependencies: dependencies, router: router), payload: payload).build()
                }
            }
        }
    }
}


/// News RIB component carrying the authenticated news dependencies for child builders.
struct NewsComponent {
    let dependencies: AppDependencies
    let router: NewsRouter
}

/// Builder for the news-list RIB.
struct NewsListBuilder {
    let component: NewsComponent

    @MainActor
    func build() -> NewsListScreen {
        NewsListScreen(
            interactor: NewsListInteractor(
                repository: component.dependencies.newsRepository,
                router: component.router,
                interactionStore: component.dependencies.articleInteractionStore
            )
        )
    }
}

/// Builder for the news-detail child RIB.
struct NewsDetailBuilder {
    let component: NewsComponent
    let payload: NewsDetailRoutePayload

    @MainActor
    func build() -> NewsDetailScreen {
        NewsDetailScreen(
            interactor: NewsDetailInteractor(
                payload: payload,
                repository: component.dependencies.newsRepository,
                interactionStore: component.dependencies.articleInteractionStore
            )
        )
    }
}
