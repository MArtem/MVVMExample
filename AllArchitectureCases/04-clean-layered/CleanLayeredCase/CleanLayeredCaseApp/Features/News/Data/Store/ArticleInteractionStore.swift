import Foundation
import SwiftData

/// Shared source of truth for article interaction state that must stay consistent across list and detail.
///
/// Ownership:
/// Created by the app dependency container and shared by news screens for the active app session.
///
/// Concurrency:
/// Main-actor isolated because current interactions are driven by UI intents and immediately reflected in SwiftUI state.
@MainActor
final class ArticleInteractionStore: ArticleInteractionManaging {
    private var states: [NewsArticle.ID: ArticleInteractionState] = [:]
    private let modelContext: ModelContext?
    private let pendingMutationStore: PendingMutationStore?
    private var currentUserID: Int?

    init(modelContext: ModelContext? = nil, pendingMutationStore: PendingMutationStore? = nil) {
        self.modelContext = modelContext
        self.pendingMutationStore = pendingMutationStore
    }

    func activateUser(id userID: Int) {
        currentUserID = userID
        states = loadPersistedStates(for: userID)
    }

    func clearActiveUser() {
        currentUserID = nil
        states = [:]
    }

    func merge(_ article: NewsArticle) -> NewsArticle {
        guard let state = states[article.id] else { return article }
        return article.applyingInteractionState(state)
    }

    func merge(_ articles: [NewsArticle]) -> [NewsArticle] {
        articles.map(merge)
    }

    func setLikeState(articleID: NewsArticle.ID, isLiked: Bool, likesCount: Int) {
        let state = ArticleInteractionState(
            isLiked: isLiked,
            likesCount: max(0, likesCount)
        )
        states[articleID] = state
        persist(state, articleID: articleID)
    }

    func update(with article: NewsArticle) {
        setLikeState(
            articleID: article.id,
            isLiked: article.isLiked,
            likesCount: article.likesCount
        )
    }

    func enqueuePendingLike(articleID: NewsArticle.ID, isLiked: Bool) {
        guard let currentUserID else { return }
        pendingMutationStore?.enqueueArticleLike(
            userID: currentUserID,
            articleID: articleID,
            isLiked: isLiked
        )
    }

    func clearPendingLike(articleID: NewsArticle.ID) {
        guard let currentUserID else { return }
        pendingMutationStore?.clearArticleLike(userID: currentUserID, articleID: articleID)
    }

    private func loadPersistedStates(for userID: Int) -> [NewsArticle.ID: ArticleInteractionState] {
        guard let modelContext else { return [:] }
        let descriptor = FetchDescriptor<PersistedArticleInteraction>(
            predicate: #Predicate { $0.userID == userID }
        )
        let records = (try? modelContext.fetch(descriptor)) ?? []
        return Dictionary(
            uniqueKeysWithValues: records.map {
                (
                    $0.articleID,
                    ArticleInteractionState(
                        isLiked: $0.isLiked,
                        likesCount: max(0, $0.likesCount)
                    )
                )
            }
        )
    }

    private func persist(_ state: ArticleInteractionState, articleID: NewsArticle.ID) {
        guard let modelContext, let currentUserID else { return }
        let key = PersistedArticleInteraction.key(userID: currentUserID, articleID: articleID)
        var descriptor = FetchDescriptor<PersistedArticleInteraction>(
            predicate: #Predicate { $0.key == key }
        )
        descriptor.fetchLimit = 1

        if let existing = try? modelContext.fetch(descriptor).first {
            existing.isLiked = state.isLiked
            existing.likesCount = state.likesCount
            existing.updatedAt = Date()
        } else {
            modelContext.insert(
                PersistedArticleInteraction(
                    userID: currentUserID,
                    articleID: articleID,
                    isLiked: state.isLiked,
                    likesCount: state.likesCount
                )
            )
        }
        try? modelContext.save()
    }
}

private struct ArticleInteractionState {
    let isLiked: Bool
    let likesCount: Int
}

private extension NewsArticle {
    func applyingInteractionState(_ state: ArticleInteractionState) -> NewsArticle {
        NewsArticle(
            id: id,
            title: title,
            excerpt: excerpt,
            source: source,
            category: category,
            rating: rating,
            thumbnailURL: thumbnailURL,
            imageURLs: imageURLs,
            publishedAt: publishedAt,
            likesCount: state.likesCount,
            commentsCount: commentsCount,
            isLiked: state.isLiked
        )
    }
}
