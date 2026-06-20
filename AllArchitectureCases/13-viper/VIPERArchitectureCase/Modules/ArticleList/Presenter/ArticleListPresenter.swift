import Foundation
import Observation

@MainActor
@Observable
final class ArticleListPresenter {
    private let interactor: ArticleListInteracting
    private let router: ArticleListRouting

    private(set) var rows: [ArticlePresentationEntity] = []
    private(set) var isLoading = false
    private(set) var message: String?

    var selectedArticle: ArticleEntity? {
        router.selectedArticle
    }

    init(interactor: ArticleListInteracting, router: ArticleListRouting) {
        self.interactor = interactor
        self.router = router
    }

    func appeared() {
        guard rows.isEmpty, !isLoading else { return }
        Task { await loadArticles() }
    }

    func refreshRequested() {
        Task { await loadArticles() }
    }

    func articleSelected(id: ArticleEntity.ID) {
        guard let article = router.articles.first(where: { $0.id == id }) else { return }
        router.routeToDetail(article)
    }

    func detailDismissed() {
        router.dismissDetail()
    }

    private func loadArticles() async {
        isLoading = true
        message = nil
        do {
            let articles = try await interactor.loadArticles()
            router.replaceArticles(articles)
            rows = articles.map(Self.makePresentationEntity)
            message = articles.isEmpty ? "No VIPER articles are available." : nil
        } catch {
            rows = []
            message = "Unable to load VIPER articles."
        }
        isLoading = false
    }

    private static func makePresentationEntity(from article: ArticleEntity) -> ArticlePresentationEntity {
        let subtitle = "\(article.readingMinutes) min read · \(article.summary)"
        return ArticlePresentationEntity(
            id: article.id,
            title: article.title,
            subtitle: subtitle,
            accessibilityLabel: "\(article.title), \(subtitle)"
        )
    }
}
