import SwiftData
import Testing
@testable import ReduxElmUDFCase

@MainActor
@Suite("Profile local store tests")
struct ProfileLocalStoreTests {


    @Test("Profile local merge load fallback and no-local update failure")
    func profileLocalMergeLoadFallbackAndNoLocalUpdateFailure() async throws {
        let context = try makeInMemoryModelContext()
        let localStore = ProfileLocalStore(modelContext: context)
        let pendingStore = PendingMutationStore(modelContext: context)
        let remoteRepository = QueueProfileRepository()
        let repository = OfflineProfileRepository(
            remote: remoteRepository,
            localStore: localStore,
            pendingMutationStore: pendingStore
        )
        let localProfile = makeLocalProfile(firstName: "Ada", lastName: "Lovelace", email: "ada@example.com")
        localStore.save(localProfile)

        let merged = localStore.merge(remoteProfile: makeLocalProfile(firstName: "Server", lastName: "Stale", email: "stale@example.com"))
        #expect(merged == localProfile)

        await remoteRepository.enqueueLoadResult(.failure(AppAPIError.offline))
        let loaded = try await repository.loadCurrentProfile(session: makeProfileSession(userID: 42))
        #expect(loaded == localProfile)

        let emptyContext = try makeInMemoryModelContext()
        let emptyRemoteRepository = QueueProfileRepository()
        let emptyRepository = OfflineProfileRepository(
            remote: emptyRemoteRepository,
            localStore: ProfileLocalStore(modelContext: emptyContext),
            pendingMutationStore: PendingMutationStore(modelContext: emptyContext)
        )
        await emptyRemoteRepository.enqueueUpdateResult(.failure(AppAPIError.offline))
        await #expect(throws: AppAPIError.offline) {
            _ = try await emptyRepository.updateProfile(
                id: 42,
                request: UpdateProfileRequest(firstName: "Ada", lastName: "Lovelace", email: "ada@example.com")
            )
        }
        #expect(fetchPendingMutations(in: emptyContext).isEmpty)
    }

    @Test("Profile update success preserves editable request fields when server acknowledgement is stale")
    func profileUpdateSuccessPreservesEditableRequestFieldsWhenServerAcknowledgementIsStale() async throws {
        let context = try makeInMemoryModelContext()
        let localStore = ProfileLocalStore(modelContext: context)
        let pendingStore = PendingMutationStore(modelContext: context)
        let remoteRepository = QueueProfileRepository()
        let repository = OfflineProfileRepository(
            remote: remoteRepository,
            localStore: localStore,
            pendingMutationStore: pendingStore
        )
        localStore.save(makeLocalProfile(firstName: "Original", lastName: "Person", email: "original@example.com"))
        pendingStore.enqueueProfileUpdate(
            userID: 42,
            profileID: 42,
            request: UpdateProfileRequest(firstName: "Queued", lastName: "Name", email: "queued@example.com")
        )
        let request = UpdateProfileRequest(firstName: "Ada", lastName: "Lovelace", email: "ada@example.com")
        await remoteRepository.enqueueUpdateResult(.success(makeLocalProfile(firstName: "Server", lastName: "Stale", email: "stale@example.com")))

        let updated = try await repository.updateProfile(id: 42, request: request)

        #expect(updated.firstName == "Ada")
        #expect(updated.lastName == "Lovelace")
        #expect(updated.email == "ada@example.com")
        #expect(localStore.profile(id: 42) == updated)
        #expect(fetchPendingMutations(in: context).isEmpty)
    }

    @Test("Profile update failure saves local editable fields and enqueues pending mutation")
    func profileUpdateFailureSavesLocalEditableFieldsAndEnqueuesPendingMutation() async throws {
        let context = try makeInMemoryModelContext()
        let localStore = ProfileLocalStore(modelContext: context)
        let pendingStore = PendingMutationStore(modelContext: context)
        let remoteRepository = QueueProfileRepository()
        let repository = OfflineProfileRepository(
            remote: remoteRepository,
            localStore: localStore,
            pendingMutationStore: pendingStore
        )
        localStore.save(makeLocalProfile(firstName: "Original", lastName: "Person", email: "original@example.com"))
        let request = UpdateProfileRequest(firstName: "Grace", lastName: "Hopper", email: "grace@example.com")
        await remoteRepository.enqueueUpdateResult(.failure(AppAPIError.offline))

        let updated = try await repository.updateProfile(id: 42, request: request)

        #expect(updated.firstName == "Grace")
        #expect(updated.lastName == "Hopper")
        #expect(updated.email == "grace@example.com")
        #expect(localStore.profile(id: 42) == updated)
        let mutation = try #require(fetchPendingMutations(in: context).first)
        #expect(pendingStore.decodeProfileUpdate(mutation) == PendingProfileUpdateMutation(profileID: 42, request: request))
    }
}

private actor QueueProfileRepository: ProfileRepository {
    private var loadResults: [Result<UserProfile, Error>] = []
    private var updateResults: [Result<UserProfile, Error>] = []

    func loadCurrentProfile(session: AuthSession) async throws -> UserProfile {
        guard !loadResults.isEmpty else { throw AppAPIError.transport("Missing queued load result") }
        return try loadResults.removeFirst().get()
    }

    func updateProfile(id: UserProfile.ID, request: UpdateProfileRequest) async throws -> UserProfile {
        guard !updateResults.isEmpty else { throw AppAPIError.transport("Missing queued update result") }
        return try updateResults.removeFirst().get()
    }

    func enqueueLoadResult(_ result: Result<UserProfile, Error>) {
        loadResults.append(result)
    }

    func enqueueUpdateResult(_ result: Result<UserProfile, Error>) {
        updateResults.append(result)
    }
}

private func makeProfileSession(userID: Int) -> AuthSession {
    AuthSession(
        accessToken: "profile-access-token-not-a-secret",
        refreshToken: "profile-refresh-token-not-a-secret",
        user: AppUser(
            id: userID,
            username: "fixture-user",
            email: "fixture@example.com",
            firstName: "Fixture",
            lastName: "User",
            imageURL: nil
        )
    )
}

private func makeLocalProfile(firstName: String, lastName: String, email: String) -> UserProfile {
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
