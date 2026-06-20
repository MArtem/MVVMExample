import SwiftData
import Testing
@testable import CleanLayeredCase

@MainActor
@Suite("Article interaction store tests")
struct ArticleInteractionStoreTests {
    @Test("Article interaction persistence is scoped by active user")
    func articleInteractionPersistenceIsScopedByActiveUser() throws {
        let context = try makeInMemoryModelContext()
        let store = ArticleInteractionStore(modelContext: context)
        let remoteArticle = makeStoredArticle(id: 10, isLiked: false, likesCount: 1)

        store.activateUser(id: 1)
        store.setLikeState(articleID: 10, isLiked: true, likesCount: 2)
        #expect(store.merge(remoteArticle).isLiked == true)
        #expect(store.merge(remoteArticle).likesCount == 2)

        store.activateUser(id: 2)
        #expect(store.merge(remoteArticle).isLiked == false)
        #expect(store.merge(remoteArticle).likesCount == 1)

        store.activateUser(id: 1)
        #expect(store.merge(remoteArticle).isLiked == true)
        #expect(store.merge(remoteArticle).likesCount == 2)
        #expect(fetchArticleInteractions(in: context).map(\.key) == [PersistedArticleInteraction.key(userID: 1, articleID: 10)])
    }



    @Test("Interaction edge cases clamp clear and preserve local optimistic acknowledgement")
    func interactionEdgeCasesClampClearAndPreserveLocalOptimisticAcknowledgement() throws {
        let context = try makeInMemoryModelContext()
        let pendingStore = PendingMutationStore(modelContext: context)
        let store = ArticleInteractionStore(modelContext: context, pendingMutationStore: pendingStore)
        let remoteArticle = makeStoredArticle(id: 10, isLiked: false, likesCount: 1)
        store.activateUser(id: 42)

        store.setLikeState(articleID: 10, isLiked: false, likesCount: -5)
        #expect(store.merge(makeStoredArticle(id: 10, isLiked: true, likesCount: 3)).likesCount == 0)
        #expect(fetchArticleInteractions(in: context).first?.likesCount == 0)

        store.setLikeState(articleID: 10, isLiked: true, likesCount: 2)
        store.clearActiveUser()
        #expect(store.merge(remoteArticle) == remoteArticle)

        store.activateUser(id: 42)
        #expect(store.merge(remoteArticle).isLiked == true)
        #expect(store.merge(remoteArticle).likesCount == 2)

        store.setLikeState(articleID: 7, isLiked: true, likesCount: 11)
        store.enqueuePendingLike(articleID: 7, isLiked: true)
        store.clearPendingLike(articleID: 7)
        let mergedAcknowledgement = store.merge(makeStoredArticle(id: 7, isLiked: false, likesCount: 10))
        #expect(fetchPendingMutations(in: context).isEmpty)
        #expect(mergedAcknowledgement.isLiked == true)
        #expect(mergedAcknowledgement.likesCount == 11)
    }

    @Test("Merge overlays local interaction state over server article state")
    func mergeOverlaysLocalInteractionStateOverServerArticleState() throws {
        let context = try makeInMemoryModelContext()
        let store = ArticleInteractionStore(modelContext: context)
        store.activateUser(id: 42)
        store.setLikeState(articleID: 7, isLiked: true, likesCount: 11)

        let merged = store.merge(makeStoredArticle(id: 7, isLiked: false, likesCount: 10))

        #expect(merged.isLiked == true)
        #expect(merged.likesCount == 11)
    }
}

private func makeStoredArticle(id: Int, isLiked: Bool, likesCount: Int) -> NewsArticle {
    NewsArticle(
        id: id,
        title: "Article \(id)",
        excerpt: "Excerpt",
        source: "Source",
        category: "General",
        rating: 4.5,
        thumbnailURL: nil,
        imageURLs: [],
        publishedAt: nil,
        likesCount: likesCount,
        commentsCount: 3,
        isLiked: isLiked
    )
}
