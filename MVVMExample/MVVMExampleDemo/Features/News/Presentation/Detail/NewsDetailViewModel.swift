import Foundation
import Observation

@MainActor
@Observable
final class NewsDetailViewModel {
    private(set) var state: NewsDetailViewState

    private let payload: NewsDetailRoutePayload
    private let repository: NewsRepository
    private let viewStateBuilder: NewsDetailViewStateBuilder
    private var article: NewsArticle?
    private var task: Task<Void, Never>?

    init(
        payload: NewsDetailRoutePayload,
        repository: NewsRepository,
        viewStateBuilder: NewsDetailViewStateBuilder = NewsDetailViewStateBuilder()
    ) {
        self.payload = payload
        self.repository = repository
        self.viewStateBuilder = viewStateBuilder
        self.state = .loading(viewStateBuilder.makePlaceholder(from: payload))
    }

    func send(_ action: NewsDetailAction) {
        switch action {
        case .appeared:
            load()
        case .retryTapped:
            load()
        case .favoriteTapped:
            toggleFavorite()
        }
    }

    private func load() {
        task?.cancel()
        state = .loading(viewStateBuilder.makePlaceholder(from: payload))

        task = Task {
            do {
                let article = try await repository.loadArticleDetail(id: payload.id)
                try Task.checkCancellation()
                self.article = article
                state = .content(viewStateBuilder.makeContent(from: article))
            } catch is CancellationError {
                return
            } catch {
                state = .error(viewStateBuilder.makeError(from: error))
            }
        }
    }

    private func toggleFavorite() {
        guard let article else { return }
        let target = !article.isLiked

        task = Task {
            do {
                let updated = try await repository.toggleLike(articleID: article.id, isLiked: target)
                try Task.checkCancellation()
                self.article = updated
                state = .content(viewStateBuilder.makeContent(from: updated))
            } catch is CancellationError {
                return
            } catch {
                state = .error(viewStateBuilder.makeError(from: error))
            }
        }
    }
}
