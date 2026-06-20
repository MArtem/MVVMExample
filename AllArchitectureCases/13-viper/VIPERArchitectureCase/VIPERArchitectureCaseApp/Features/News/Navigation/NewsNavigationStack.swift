import SwiftUI

/// Composes the news navigation stack and creates screen Presenters at route boundaries.
struct NewsNavigationStack: View {
    @Bindable var router: NewsRouter
    let dependencies: AppDependencies

    var body: some View {
        NavigationStack(path: $router.path) {
            NewsListModuleBuilder.build(
                repository: dependencies.newsRepository,
                router: router,
                interactionStore: dependencies.articleInteractionStore
            )
            .navigationDestination(for: NewsRoute.self) { route in
                switch route {
                case .detail(let payload):
                    NewsDetailModuleBuilder.build(
                        payload: payload,
                        repository: dependencies.newsRepository,
                        interactionStore: dependencies.articleInteractionStore
                    )
                }
            }
        }
    }
}


/// VIPER Builder for the news-list module.
@MainActor
struct NewsListModuleBuilder {
    static func build(
        repository: NewsRepository,
        router: NewsRouter,
        interactionStore: ArticleInteractionStore
    ) -> NewsListScreen {
        NewsListScreen(
            presenter: NewsListPresenter(
                repository: repository,
                router: router,
                interactionStore: interactionStore
            )
        )
    }
}

/// VIPER Builder for the article-detail module.
@MainActor
struct NewsDetailModuleBuilder {
    static func build(
        payload: NewsDetailRoutePayload,
        repository: NewsRepository,
        interactionStore: ArticleInteractionStore
    ) -> NewsDetailScreen {
        NewsDetailScreen(
            presenter: NewsDetailPresenter(
                payload: payload,
                repository: repository,
                interactionStore: interactionStore
            )
        )
    }
}
