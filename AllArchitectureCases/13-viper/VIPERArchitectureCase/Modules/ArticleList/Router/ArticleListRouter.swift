import Foundation
import Observation
import SwiftUI

@MainActor
protocol ArticleListRouting: AnyObject {
    var articles: [ArticleEntity] { get }
    var selectedArticle: ArticleEntity? { get }
    func replaceArticles(_ articles: [ArticleEntity])
    func routeToDetail(_ article: ArticleEntity)
    func dismissDetail()
}

@MainActor
@Observable
final class ArticleListRouter: ArticleListRouting {
    private(set) var articles: [ArticleEntity] = []
    private(set) var selectedArticle: ArticleEntity?

    func replaceArticles(_ articles: [ArticleEntity]) {
        self.articles = articles
    }

    func routeToDetail(_ article: ArticleEntity) {
        selectedArticle = article
    }

    func dismissDetail() {
        selectedArticle = nil
    }

    func makeDetailView(for article: ArticleEntity) -> some View {
        ArticleDetailView(article: article)
    }
}
