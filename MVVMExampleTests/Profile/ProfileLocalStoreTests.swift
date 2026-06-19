import SwiftData
import Testing
@testable import MVVMExample

@MainActor
@Suite("Profile local store tests")
struct ProfileLocalStoreTests {
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
    private var updateResults: [Result<UserProfile, Error>] = []

    func loadCurrentProfile(session: AuthSession) async throws -> UserProfile {
        throw AppAPIError.transport("Unsupported test path")
    }

    func updateProfile(id: UserProfile.ID, request: UpdateProfileRequest) async throws -> UserProfile {
        guard !updateResults.isEmpty else { throw AppAPIError.transport("Missing queued update result") }
        return try updateResults.removeFirst().get()
    }

    func enqueueUpdateResult(_ result: Result<UserProfile, Error>) {
        updateResults.append(result)
    }
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
