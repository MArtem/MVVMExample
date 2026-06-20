import Testing
@testable import VIPERArchitectureCase

@MainActor
struct ArticleListPresenterTests {
    @Test func loadMapsInteractorEntitiesIntoPresentationRows() async throws {
        let router = ArticleListRouter()
        let presenter = ArticleListPresenter(interactor: ArticleListInteractor(), router: router)

        presenter.refreshRequested()
        try await Task.sleep(for: .milliseconds(100))

        #expect(presenter.rows.count == 3)
        #expect(router.articles.count == 3)
    }
}
