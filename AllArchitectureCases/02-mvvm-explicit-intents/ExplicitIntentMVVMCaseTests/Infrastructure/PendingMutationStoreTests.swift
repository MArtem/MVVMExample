import Foundation
import SwiftData
import Testing
@testable import ExplicitIntentMVVMCase

@MainActor
@Suite("Pending mutation store tests")
struct PendingMutationStoreTests {
    @Test("Article like mutations use deterministic key and replace payload")
    func articleLikeMutationsUseDeterministicKeyAndReplacePayload() throws {
        let context = try makeInMemoryModelContext()
        let store = PendingMutationStore(modelContext: context)

        store.enqueueArticleLike(userID: 42, articleID: 7, isLiked: true)
        store.enqueueArticleLike(userID: 42, articleID: 7, isLiked: false)

        let mutations = fetchPendingMutations(in: context)
        let mutation = try #require(mutations.first)
        #expect(mutations.count == 1)
        #expect(mutation.key == PersistedPendingMutation.articleLikeKey(userID: 42, articleID: 7))
        #expect(store.decodeArticleLike(mutation) == PendingArticleLikeMutation(articleID: 7, isLiked: false))
        #expect(mutation.retryCount == 0)
        #expect(mutation.lastAttemptAt == nil)
        #expect(mutation.lastErrorDescription == nil)
    }

    @Test("Profile update mutations use deterministic key and replace payload")
    func profileUpdateMutationsUseDeterministicKeyAndReplacePayload() throws {
        let context = try makeInMemoryModelContext()
        let store = PendingMutationStore(modelContext: context)
        let first = UpdateProfileRequest(firstName: "Ada", lastName: "Lovelace", email: "ada@example.com")
        let second = UpdateProfileRequest(firstName: "Grace", lastName: "Hopper", email: "grace@example.com")

        store.enqueueProfileUpdate(userID: 42, profileID: 42, request: first)
        store.enqueueProfileUpdate(userID: 42, profileID: 42, request: second)

        let mutations = fetchPendingMutations(in: context)
        let mutation = try #require(mutations.first)
        #expect(mutations.count == 1)
        #expect(mutation.key == PersistedPendingMutation.profileUpdateKey(userID: 42, profileID: 42))
        #expect(store.decodeProfileUpdate(mutation) == PendingProfileUpdateMutation(profileID: 42, request: second))
    }



    @Test("Pending sync failure backoff and invalid payload behavior")
    func pendingSyncFailureBackoffAndInvalidPayloadBehavior() async throws {
        let context = try makeInMemoryModelContext()
        let store = PendingMutationStore(modelContext: context)
        let newsRepository = ControllablePendingNewsRepository()
        let profileRepository = ControllablePendingProfileRepository()
        let syncService = PendingMutationSyncService(
            pendingStore: store,
            newsRepository: newsRepository,
            profileRepository: profileRepository
        )
        store.enqueueArticleLike(userID: 42, articleID: 7, isLiked: true)

        syncService.syncPendingMutations(for: 42)
        _ = await newsRepository.waitForToggleCall(at: 0)
        await newsRepository.completeToggle(at: 0, with: .failure(AppAPIError.offline))
        await drainPendingMainActorTasks()

        let failedMutation = try #require(fetchPendingMutations(in: context).first)
        #expect(failedMutation.key == PersistedPendingMutation.articleLikeKey(userID: 42, articleID: 7))
        #expect(failedMutation.retryCount == 1)
        #expect(failedMutation.lastAttemptAt != nil)
        #expect(failedMutation.lastErrorDescription?.isEmpty == false)

        let now = Date(timeIntervalSince1970: 2_000)
        store.markAttempt(failedMutation, at: now)
        store.markFailure(failedMutation, error: AppAPIError.offline, at: now)
        #expect(store.dueMutations(for: 42, now: now.addingTimeInterval(1)).isEmpty)
        #expect(store.dueMutations(for: 42, now: now.addingTimeInterval(20)).map(\.key) == [failedMutation.key])

        store.clearArticleLike(userID: 42, articleID: 7)
        context.insert(PersistedPendingMutation(
            key: PersistedPendingMutation.articleLikeKey(userID: 42, articleID: 8),
            userID: 42,
            kind: PendingMutationKind.articleLike,
            payloadData: Data("invalid".utf8)
        ))
        try context.save()

        syncService.syncPendingMutations(for: 42)
        await drainPendingMainActorTasks()

        let invalidPayloadMutation = try #require(fetchPendingMutations(in: context).first)
        #expect(invalidPayloadMutation.retryCount == 1)
        #expect(invalidPayloadMutation.lastErrorDescription?.isEmpty == false)
    }

    @Test("Pending sync clears successful article and profile mutations")
    func pendingSyncClearsSuccessfulArticleAndProfileMutations() async throws {
        let context = try makeInMemoryModelContext()
        let store = PendingMutationStore(modelContext: context)
        let newsRepository = ControllablePendingNewsRepository()
        let profileRepository = ControllablePendingProfileRepository()
        let syncService = PendingMutationSyncService(
            pendingStore: store,
            newsRepository: newsRepository,
            profileRepository: profileRepository
        )
        let profileRequest = UpdateProfileRequest(firstName: "Ada", lastName: "Lovelace", email: "ada@example.com")
        store.enqueueArticleLike(userID: 42, articleID: 7, isLiked: true)
        store.enqueueProfileUpdate(userID: 42, profileID: 42, request: profileRequest)

        syncService.syncPendingMutations(for: 42)
        let likeCall = await newsRepository.waitForToggleCall(at: 0)
        await newsRepository.completeToggle(at: 0, with: .success(makePendingArticle(id: 7, isLiked: false, likesCount: 10)))
        let profileCall = await profileRepository.waitForUpdateCall(at: 0)
        await profileRepository.completeUpdate(at: 0, with: .success(makePendingProfile(firstName: "Server", lastName: "Stale", email: "stale@example.com")))
        await drainPendingMainActorTasks()

        #expect(likeCall == PendingToggleCall(articleID: 7, isLiked: true))
        #expect(profileCall == PendingProfileCall(id: 42, request: profileRequest))
        #expect(fetchPendingMutations(in: context).isEmpty)
    }
}

private struct PendingToggleCall: Equatable {
    let articleID: NewsArticle.ID
    let isLiked: Bool
}

private actor ControllablePendingNewsRepository: NewsRepository {
    private var toggleCalls: [PendingToggleCall] = []
    private var toggleContinuations: [Int: CheckedContinuation<NewsArticle, Error>] = [:]
    private var toggleWaiters: [Int: CheckedContinuation<PendingToggleCall, Never>] = [:]

    func loadNews(page: NewsPageRequest) async throws -> [NewsArticle] { throw AppAPIError.transport("Unsupported test path") }
    func refreshNews(page: NewsPageRequest) async throws -> [NewsArticle] { throw AppAPIError.transport("Unsupported test path") }
    func loadArticleDetail(id: NewsArticle.ID) async throws -> NewsArticle { throw AppAPIError.transport("Unsupported test path") }

    func toggleLike(articleID: NewsArticle.ID, isLiked: Bool) async throws -> NewsArticle {
        let index = toggleCalls.count
        let call = PendingToggleCall(articleID: articleID, isLiked: isLiked)
        toggleCalls.append(call)
        toggleWaiters.removeValue(forKey: index)?.resume(returning: call)
        return try await withCheckedThrowingContinuation { continuation in
            toggleContinuations[index] = continuation
        }
    }

    func waitForToggleCall(at index: Int) async -> PendingToggleCall {
        if toggleCalls.indices.contains(index) { return toggleCalls[index] }
        return await withCheckedContinuation { toggleWaiters[index] = $0 }
    }

    func completeToggle(at index: Int, with result: Result<NewsArticle, Error>) {
        toggleContinuations.removeValue(forKey: index)?.resume(with: result)
    }
}

private struct PendingProfileCall: Equatable {
    let id: UserProfile.ID
    let request: UpdateProfileRequest
}

private actor ControllablePendingProfileRepository: ProfileRepository {
    private var updateCalls: [PendingProfileCall] = []
    private var updateContinuations: [Int: CheckedContinuation<UserProfile, Error>] = [:]
    private var updateWaiters: [Int: CheckedContinuation<PendingProfileCall, Never>] = [:]

    func loadCurrentProfile(session: AuthSession) async throws -> UserProfile {
        throw AppAPIError.transport("Unsupported test path")
    }

    func updateProfile(id: UserProfile.ID, request: UpdateProfileRequest) async throws -> UserProfile {
        let index = updateCalls.count
        let call = PendingProfileCall(id: id, request: request)
        updateCalls.append(call)
        updateWaiters.removeValue(forKey: index)?.resume(returning: call)
        return try await withCheckedThrowingContinuation { continuation in
            updateContinuations[index] = continuation
        }
    }

    func waitForUpdateCall(at index: Int) async -> PendingProfileCall {
        if updateCalls.indices.contains(index) { return updateCalls[index] }
        return await withCheckedContinuation { updateWaiters[index] = $0 }
    }

    func completeUpdate(at index: Int, with result: Result<UserProfile, Error>) {
        updateContinuations.removeValue(forKey: index)?.resume(with: result)
    }
}

private func makePendingArticle(id: Int, isLiked: Bool, likesCount: Int) -> NewsArticle {
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

private func makePendingProfile(firstName: String, lastName: String, email: String) -> UserProfile {
    UserProfile(
        id: 42,
        username: "fixture-user",
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: nil,
        imageURL: nil,
        companyTitle: nil
    )
}

@MainActor
private func drainPendingMainActorTasks() async {
    for _ in 0..<10 { await Task.yield() }
}
