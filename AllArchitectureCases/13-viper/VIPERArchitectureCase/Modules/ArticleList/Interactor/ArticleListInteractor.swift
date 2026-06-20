import Foundation

protocol ArticleListInteracting {
    func loadArticles() async throws -> [ArticleEntity]
}

struct ArticleListInteractor: ArticleListInteracting {
    func loadArticles() async throws -> [ArticleEntity] {
        [
            ArticleEntity(
                id: UUID(uuidString: "3A7C16A2-186D-48B2-B42E-936947DB61A1")!,
                title: "VIPER separates scene roles",
                summary: "The interactor owns deterministic data retrieval and leaves formatting to the presenter.",
                readingMinutes: 3
            ),
            ArticleEntity(
                id: UUID(uuidString: "2B657E8C-4A6A-466C-AB7C-52A19A45C7F2")!,
                title: "Presenter coordinates presentation",
                summary: "The presenter maps entities into display-ready rows and updates view state.",
                readingMinutes: 4
            ),
            ArticleEntity(
                id: UUID(uuidString: "B5595410-C237-4C0A-87FD-06F9FB92B124")!,
                title: "Router owns navigation",
                summary: "The router keeps route state and creates destination views without business logic.",
                readingMinutes: 2
            )
        ]
    }
}
