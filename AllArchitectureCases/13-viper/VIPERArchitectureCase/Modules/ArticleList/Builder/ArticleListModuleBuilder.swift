import SwiftUI

@MainActor
enum ArticleListModuleBuilder {
    static func build() -> some View {
        let interactor = ArticleListInteractor()
        let router = ArticleListRouter()
        let presenter = ArticleListPresenter(interactor: interactor, router: router)
        return ArticleListView(presenter: presenter, router: router)
    }
}
