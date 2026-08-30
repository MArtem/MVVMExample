import Testing
@testable import MVCMigrationCase

@MainActor
@Suite("Profile edit Store tests")
struct ProfileEditControllerTests {
    @Test("Save trims request, publishes updated profile, and pops route")
    func saveTrimsRequestPublishesUpdatedProfileAndPopsRoute() async {
        let repository = ControllableProfileRepository()
        let router = ProfileRouter()
        let payload = makePayload()
        router.openEdit(payload)

        var savedProfile: UserProfile?
        let store = ProfileEditController(
            payload: payload,
            repository: repository,
            router: router,
            onSaveSuccess: { savedProfile = $0 }
        )
        store.firstName = "  Ada  "
        store.lastName = "  Lovelace\n"
        store.email = "  ada@example.com  "

        store.saveTapped()
        let call = await repository.waitForUpdateCall()
        await repository.waitForUpdateContinuation()

        #expect(store.state.isSaving == true)
        #expect(call.id == payload.id)
        #expect(call.request == UpdateProfileRequest(
            firstName: "Ada",
            lastName: "Lovelace",
            email: "ada@example.com"
        ))

        let updatedProfile = makeProfile(firstName: "Ada", lastName: "Lovelace", email: "ada@example.com")
        await repository.completeUpdate(with: .success(updatedProfile))
        await drainMainActorTasks()

        #expect(store.state.isSaving == false)
        #expect(store.state.errorMessage == nil)
        #expect(savedProfile == updatedProfile)
        #expect(router.path.isEmpty == true)
    }

    @Test("Save failure uses user-safe error mapping and keeps route visible")
    func saveFailureUsesUserSafeErrorMappingAndKeepsRouteVisible() async {
        let repository = ControllableProfileRepository()
        let router = ProfileRouter()
        let payload = makePayload()
        router.openEdit(payload)

        let store = ProfileEditController(
            payload: payload,
            repository: repository,
            router: router,
            onSaveSuccess: { _ in Issue.record("Save success callback must not run on failure") }
        )

        store.saveTapped()
        _ = await repository.waitForUpdateCall()
        await repository.waitForUpdateContinuation()
        await repository.completeUpdate(with: .failure(AppAPIError.offline))
        await drainMainActorTasks()

        #expect(store.state.isSaving == false)
        #expect(store.state.errorMessage == AppErrorMapper.userMessage(for: AppAPIError.offline))
        #expect(router.path.isEmpty == false)
    }

    @Test("Profile edit save success updates profile presentation")
    func profileEditSaveSuccessUpdatesProfilePresentation() async {
        let repository = ControllableProfileRepository()
        let router = ProfileRouter()
        let profileStore = ProfileController(
            session: makeEditAuthSession(),
            repository: repository,
            router: router,
            onLogout: {}
        )
        let payload = makePayload()
        router.openEdit(payload)
        let editStore = ProfileEditController(
            payload: payload,
            repository: repository,
            router: router,
            onSaveSuccess: { profileStore.profileUpdated($0) }
        )

        editStore.firstName = "  Katherine  "
        editStore.lastName = "  Johnson  "
        editStore.email = "  katherine@example.com  "

        editStore.saveTapped()
        let call = await repository.waitForUpdateCall()
        await repository.waitForUpdateContinuation()

        #expect(call.request == UpdateProfileRequest(
            firstName: "Katherine",
            lastName: "Johnson",
            email: "katherine@example.com"
        ))

        await repository.completeUpdate(with: .success(makeProfile(
            firstName: "Katherine",
            lastName: "Johnson",
            email: "katherine@example.com"
        )))
        await drainMainActorTasks()

        guard case .content(let content) = profileStore.state else {
            Issue.record("Expected updated profile content")
            return
        }
        #expect(content.displayName == "Katherine Johnson")
        #expect(content.emailText == "katherine@example.com")
        #expect(router.path.isEmpty == true)
    }
}

private struct ProfileUpdateCall: Equatable {
    let id: UserProfile.ID
    let request: UpdateProfileRequest
}

private actor ControllableProfileRepository: ProfileRepository {
    private var updateCall: ProfileUpdateCall?
    private var updateCallContinuation: CheckedContinuation<ProfileUpdateCall, Never>?
    private var updateContinuation: CheckedContinuation<UserProfile, Error>?
    private var updateContinuationReady: CheckedContinuation<Void, Never>?
    private var pendingUpdateResult: Result<UserProfile, Error>?

    func loadCurrentProfile(session: AuthSession) async throws -> UserProfile {
        throw AppAPIError.transport("Unsupported test path")
    }

    func updateProfile(id: UserProfile.ID, request: UpdateProfileRequest) async throws -> UserProfile {
        let call = ProfileUpdateCall(id: id, request: request)
        updateCall = call
        updateCallContinuation?.resume(returning: call)
        updateCallContinuation = nil

        return try await withCheckedThrowingContinuation { continuation in
            if let pendingUpdateResult {
                self.pendingUpdateResult = nil
                continuation.resume(with: pendingUpdateResult)
            } else {
                updateContinuation = continuation
                updateContinuationReady?.resume()
                updateContinuationReady = nil
            }
        }
    }

    func waitForUpdateCall() async -> ProfileUpdateCall {
        if let updateCall { return updateCall }
        return await withCheckedContinuation { continuation in
            updateCallContinuation = continuation
        }
    }

    func waitForUpdateContinuation() async {
        if updateContinuation != nil { return }
        await withCheckedContinuation { continuation in
            updateContinuationReady = continuation
        }
    }

    func completeUpdate(with result: Result<UserProfile, Error>) {
        guard let continuation = updateContinuation else {
            pendingUpdateResult = result
            return
        }
        updateContinuation = nil
        continuation.resume(with: result)
    }
}

private func makePayload() -> ProfileEditRoutePayload {
    ProfileEditRoutePayload(
        id: 42,
        firstName: "Grace",
        lastName: "Hopper",
        email: "grace@example.com"
    )
}

private func makeProfile(firstName: String, lastName: String, email: String) -> UserProfile {
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

private func makeEditAuthSession() -> AuthSession {
    AuthSession(
        accessToken: "profile-edit-access-credential-not-a-secret",
        refreshToken: "profile-edit-refresh-credential-not-a-secret",
        user: AppUser(
            id: 42,
            username: "fixture-user",
            email: "grace@example.com",
            firstName: "Grace",
            lastName: "Hopper",
            imageURL: nil
        )
    )
}

@MainActor
private func drainMainActorTasks() async {
    for _ in 0..<10 {
        await Task.yield()
    }
}
