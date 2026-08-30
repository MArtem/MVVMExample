import Foundation
import SwiftData

/// Persistence boundary for durable app-local state.
///
/// Data-safety rule: keep token-like secrets out of SwiftData and make save/load failure behavior explicit for callers.
struct PendingArticleLikeMutation: Codable, Equatable, Sendable {
    let articleID: Int
    let isLiked: Bool
    /// Identifies one concrete optimistic action. Existing persisted payloads predate this field
    /// and decode with `nil`; every newly enqueued action receives a fresh value.
    let operationID: UUID?

    init(articleID: Int, isLiked: Bool, operationID: UUID? = UUID()) {
        self.articleID = articleID
        self.isLiked = isLiked
        self.operationID = operationID
    }
}

/// Immutable identity of the exact durable mutation payload a caller is acknowledging.
///
/// The deterministic queue key intentionally coalesces repeated user actions. The payload bytes
/// add the missing version boundary, so an older request cannot clear or back off a newer action
/// that reused the same key.
struct PendingMutationReceipt: Sendable, Equatable {
    let key: String
    let payloadData: Data
}

/// Persistence boundary for durable app-local state.
///
/// Data-safety rule: keep token-like secrets out of SwiftData and make save/load failure behavior explicit for callers.
struct PendingProfileUpdateMutation: Codable, Equatable, Sendable {
    let profileID: Int
    let request: UpdateProfileRequest
}

/// Persistence boundary for durable app-local state.
///
/// Data-safety rule: keep token-like secrets out of SwiftData and make save/load failure behavior explicit for callers.
enum PendingMutationKind {
    static let articleLike = "articleLike"
    static let profileUpdate = "profileUpdate"
}

/// SwiftData-backed queue for user mutations that were applied locally but not yet acknowledged by the server.
///
/// Queue policy:
/// - deterministic keys coalesce repeated mutations for the same logical user action;
/// - payloads contain non-secret user state only;
/// - retry metadata is durable so relaunch does not lose backoff state.
@MainActor
final class PendingMutationStore {
    private let modelContext: ModelContext
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @discardableResult
    func enqueueArticleLike(userID: Int, articleID: Int, isLiked: Bool) -> PendingMutationReceipt? {
        let payload = PendingArticleLikeMutation(articleID: articleID, isLiked: isLiked)
        return upsert(
            key: PersistedPendingMutation.articleLikeKey(userID: userID, articleID: articleID),
            userID: userID,
            kind: PendingMutationKind.articleLike,
            payload: payload
        )
    }

    func clearArticleLike(userID: Int, articleID: Int) {
        delete(key: PersistedPendingMutation.articleLikeKey(userID: userID, articleID: articleID))
    }

    func clear(_ receipt: PendingMutationReceipt) {
        guard pendingMutation(key: receipt.key)?.payloadData == receipt.payloadData else { return }
        delete(key: receipt.key)
    }

    func enqueueProfileUpdate(userID: Int, profileID: Int, request: UpdateProfileRequest) {
        let payload = PendingProfileUpdateMutation(profileID: profileID, request: request)
        _ = upsert(
            key: PersistedPendingMutation.profileUpdateKey(userID: userID, profileID: profileID),
            userID: userID,
            kind: PendingMutationKind.profileUpdate,
            payload: payload
        )
    }

    func clearProfileUpdate(userID: Int, profileID: Int) {
        delete(key: PersistedPendingMutation.profileUpdateKey(userID: userID, profileID: profileID))
    }

    func dueMutations(for userID: Int, now: Date = Date()) -> [PersistedPendingMutation] {
        let descriptor = FetchDescriptor<PersistedPendingMutation>(
            predicate: #Predicate { $0.userID == userID },
            sortBy: [SortDescriptor(\PersistedPendingMutation.createdAt)]
        )
        let records = (try? modelContext.fetch(descriptor)) ?? []
        return records.filter { $0.isDue(now: now) }
    }

    func receipt(for mutation: PersistedPendingMutation) -> PendingMutationReceipt {
        PendingMutationReceipt(key: mutation.key, payloadData: mutation.payloadData)
    }

    func markAttempt(_ receipt: PendingMutationReceipt, at date: Date = Date()) {
        guard let mutation = pendingMutation(key: receipt.key), mutation.payloadData == receipt.payloadData else { return }
        mutation.lastAttemptAt = date
        mutation.updatedAt = date
        try? modelContext.save()
    }

    func markFailure(_ receipt: PendingMutationReceipt, error: Error, at date: Date = Date()) {
        guard let mutation = pendingMutation(key: receipt.key), mutation.payloadData == receipt.payloadData else { return }
        mutation.retryCount += 1
        mutation.lastErrorDescription = String(describing: error)
        mutation.updatedAt = date
        try? modelContext.save()
    }

    func decodeArticleLike(_ mutation: PersistedPendingMutation) -> PendingArticleLikeMutation? {
        guard mutation.kind == PendingMutationKind.articleLike else { return nil }
        return try? decoder.decode(PendingArticleLikeMutation.self, from: mutation.payloadData)
    }

    func decodeProfileUpdate(_ mutation: PersistedPendingMutation) -> PendingProfileUpdateMutation? {
        guard mutation.kind == PendingMutationKind.profileUpdate else { return nil }
        return try? decoder.decode(PendingProfileUpdateMutation.self, from: mutation.payloadData)
    }

    private func upsert<Payload: Encodable>(key: String, userID: Int, kind: String, payload: Payload) -> PendingMutationReceipt? {
        guard let payloadData = try? encoder.encode(payload) else { return nil }
        if let existing = pendingMutation(key: key) {
            existing.payloadData = payloadData
            existing.retryCount = 0
            existing.lastAttemptAt = nil
            existing.lastErrorDescription = nil
            existing.updatedAt = Date()
        } else {
            modelContext.insert(
                PersistedPendingMutation(
                    key: key,
                    userID: userID,
                    kind: kind,
                    payloadData: payloadData
                )
            )
        }
        try? modelContext.save()
        return PendingMutationReceipt(key: key, payloadData: payloadData)
    }

    private func delete(key: String) {
        guard let existing = pendingMutation(key: key) else { return }
        modelContext.delete(existing)
        try? modelContext.save()
    }

    private func pendingMutation(key: String) -> PersistedPendingMutation? {
        var descriptor = FetchDescriptor<PersistedPendingMutation>(
            predicate: #Predicate { $0.key == key }
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }
}

/// Replays pending local mutations against the current server contract.
///
/// The current demo backend does not expose a durable idempotency contract, so idempotency is enforced locally through deterministic queue keys. If a production backend adds idempotency headers/operation IDs, this service is the boundary where that transport contract should be attached.
@MainActor
final class PendingMutationSyncService {
    private let pendingStore: PendingMutationStore
    private let newsRepository: NewsRepository
    private let profileRepository: ProfileRepository

    private var syncTask: Task<Void, Never>?

    init(
        pendingStore: PendingMutationStore,
        newsRepository: NewsRepository,
        profileRepository: ProfileRepository
    ) {
        self.pendingStore = pendingStore
        self.newsRepository = newsRepository
        self.profileRepository = profileRepository
    }

    func syncPendingMutations(for userID: Int) {
        syncTask?.cancel()
        syncTask = Task { [pendingStore, newsRepository, profileRepository] in
            for mutation in pendingStore.dueMutations(for: userID) {
                let receipt = pendingStore.receipt(for: mutation)
                do {
                    try Task.checkCancellation()
                    pendingStore.markAttempt(receipt)
                    switch mutation.kind {
                    case PendingMutationKind.articleLike:
                        guard let payload = pendingStore.decodeArticleLike(mutation) else {
                            pendingStore.markFailure(receipt, error: PendingMutationSyncError.invalidPayload)
                            continue
                        }
                        _ = try await newsRepository.toggleLike(
                            articleID: payload.articleID,
                            isLiked: payload.isLiked
                        )
                        pendingStore.clear(receipt)

                    case PendingMutationKind.profileUpdate:
                        guard let payload = pendingStore.decodeProfileUpdate(mutation) else {
                            pendingStore.markFailure(receipt, error: PendingMutationSyncError.invalidPayload)
                            continue
                        }
                        _ = try await profileRepository.updateProfile(
                            id: payload.profileID,
                            request: payload.request
                        )
                        pendingStore.clear(receipt)

                    default:
                        pendingStore.markFailure(receipt, error: PendingMutationSyncError.unsupportedKind(mutation.kind))
                    }
                } catch is CancellationError {
                    return
                } catch {
                    pendingStore.markFailure(receipt, error: error)
                }
            }
        }
    }

    func cancel() {
        syncTask?.cancel()
        syncTask = nil
    }
}

/// Persistence boundary for durable app-local state.
///
/// Data-safety rule: keep token-like secrets out of SwiftData and make save/load failure behavior explicit for callers.
private enum PendingMutationSyncError: Error {
    case invalidPayload
    case unsupportedKind(String)
}
