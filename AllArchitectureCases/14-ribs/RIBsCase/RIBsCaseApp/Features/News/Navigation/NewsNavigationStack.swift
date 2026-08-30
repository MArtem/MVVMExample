import SwiftUI

/// Composes the news navigation stack and creates screen Interactors at route boundaries.
struct NewsNavigationStack: View {
    @Bindable var router: NewsRouter
    let dependencies: AppDependencies

    var body: some View {
        NavigationStack(path: $router.path) {
            let component = makeComponent()
            NewsListBuilder(component: component).build()
            .navigationDestination(for: NewsRoute.self) { route in
                switch route {
                case .detail(let payload):
                    NewsDetailBuilder(component: component, payload: payload).build()
                }
            }
        }
    }
}


private extension NewsNavigationStack {
    func makeComponent() -> NewsComponent {
        NewsComponent(
            repository: dependencies.newsRepository,
            interactionStore: dependencies.articleInteractionStore,
            router: router
        )
    }
}

/// News RIB component carrying only the authenticated news subtree dependencies.
struct NewsComponent {
    let repository: NewsRepository
    let interactionStore: ArticleInteractionStore
    let router: NewsRouter
}

/// Builder for the news-list RIB.
struct NewsListBuilder {
    let component: NewsComponent

    @MainActor
    func build() -> NewsListScreen {
        NewsListScreen(
            interactor: NewsListInteractor(
                repository: component.repository,
                router: component.router,
                interactionStore: component.interactionStore
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
                repository: component.repository,
                interactionStore: component.interactionStore
            )
        )
    }
}
