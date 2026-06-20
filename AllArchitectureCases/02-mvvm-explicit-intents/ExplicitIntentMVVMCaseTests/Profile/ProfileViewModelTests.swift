import Testing
@testable import ExplicitIntentMVVMCase

@MainActor
@Suite("Profile ViewModel tests")
struct ProfileViewModelTests {
    @Test("Appeared loads current profile into content state")
    func appearedLoadsCurrentProfileIntoContentState() async {
        let repository = ControllableProfileLoadRepository()
        let viewModel = makeProfileViewModel(repository: repository)

        viewModel.appeared()
        _ = await repository.waitForLoadRequest(at: 0)
        await repository.waitForLoadContinuation(at: 0)
        await repository.completeLoad(at: 0, with: .success(makeUserProfile(firstName: "Ada", lastName: "Lovelace")))
        await drainProfileMainActorTasks()

        guard case .content(let content) = viewModel.state else {
            Issue.record("Expected content state")
            return
        }
        #expect(content.displayName == "Ada Lovelace")
        #expect(content.emailText == "ada@example.com")
    }

    @Test("Load failure maps to profile error state")
    func loadFailureMapsToProfileErrorState() async {
        let repository = ControllableProfileLoadRepository()
        let viewModel = makeProfileViewModel(repository: repository)

        viewModel.appeared()
        _ = await repository.waitForLoadRequest(at: 0)
        await repository.waitForLoadContinuation(at: 0)
        await repository.completeLoad(at: 0, with: .failure(AppAPIError.timeout))
        await drainProfileMainActorTasks()

        guard case .error(let message) = viewModel.state else {
            Issue.record("Expected error state")
            return
        }
        #expect(message.title == "Couldn’t load profile")
        #expect(message.message == "The request took too long. Please try again.")
    }

    @Test("Profile update applies returned profile without network reload")
    func profileUpdateAppliesReturnedProfileWithoutNetworkReload() async {
        let repository = ControllableProfileLoadRepository()
        let viewModel = makeProfileViewModel(repository: repository)

        viewModel.profileUpdated(makeUserProfile(firstName: "Grace", lastName: "Hopper"))

        guard case .content(let content) = viewModel.state else {
            Issue.record("Expected content state")
            return
        }
        #expect(content.displayName == "Grace Hopper")
        #expect(await repository.loadRequestCount() == 0)
    }

    @Test("Edit and logout intents delegate to router and session owner")
    func editAndLogoutIntentsDelegateToRouterAndSessionOwner() async {
        let repository = ControllableProfileLoadRepository()
        let router = ProfileRouter()
        var logoutCount = 0
        let viewModel = ProfileViewModel(
            session: makeAuthSession(),
            repository: repository,
            router: router,
            onLogout: { logoutCount += 1 }
        )

        viewModel.editTapped()
        #expect(router.path.isEmpty == true)

        viewModel.profileUpdated(makeUserProfile(firstName: "Ada", lastName: "Lovelace"))
        viewModel.editTapped()
        viewModel.logoutTapped()

        #expect(router.path.isEmpty == false)
        #expect(logoutCount == 1)
    }
}

private actor ControllableProfileLoadRepository: ProfileRepository {
    private var loadRequests: [AuthSession] = []
    private var loadContinuations: [Int: CheckedContinuation<UserProfile, Error>] = [:]
    private var loadWaiters: [Int: CheckedContinuation<AuthSession, Never>] = [:]
    private var loadContinuationWaiters: [Int: CheckedContinuation<Void, Never>] = [:]

    func loadCurrentProfile(session: AuthSession) async throws -> UserProfile {
        let index = loadRequests.count
        loadRequests.append(session)
        loadWaiters.removeValue(forKey: index)?.resume(returning: session)
        return try await withCheckedThrowingContinuation { continuation in
            loadContinuations[index] = continuation
            loadContinuationWaiters.removeValue(forKey: index)?.resume()
        }
    }

    func updateProfile(id: UserProfile.ID, request: UpdateProfileRequest) async throws -> UserProfile {
        throw AppAPIError.transport("Unsupported test path")
    }

    func waitForLoadRequest(at index: Int) async -> AuthSession {
        if loadRequests.indices.contains(index) { return loadRequests[index] }
        return await withCheckedContinuation { loadWaiters[index] = $0 }
    }

    func waitForLoadContinuation(at index: Int) async {
        if loadContinuations[index] != nil { return }
        await withCheckedContinuation { loadContinuationWaiters[index] = $0 }
    }

    func completeLoad(at index: Int, with result: Result<UserProfile, Error>) {
        loadContinuations.removeValue(forKey: index)?.resume(with: result)
    }

    func loadRequestCount() -> Int { loadRequests.count }
}

@MainActor
private func makeProfileViewModel(repository: ControllableProfileLoadRepository) -> ProfileViewModel {
    ProfileViewModel(
        session: makeAuthSession(),
        repository: repository,
        router: ProfileRouter(),
        onLogout: {}
    )
}

private func makeUserProfile(firstName: String, lastName: String) -> UserProfile {
    UserProfile(
        id: 42,
        username: "ada",
        email: "ada@example.com",
        firstName: firstName,
        lastName: lastName,
        phone: nil,
        imageURL: nil,
        companyTitle: nil
    )
}

private func makeAuthSession() -> AuthSession {
    AuthSession(
        accessToken: "demo-access-credential-not-a-secret",
        refreshToken: "demo-refresh-credential-not-a-secret",
        user: AppUser(
            id: 42,
            username: "ada",
            email: "ada@example.com",
            firstName: "Ada",
            lastName: "Lovelace",
            imageURL: nil
        )
    )
}

@MainActor
private func drainProfileMainActorTasks() async {
    for _ in 0..<10 { await Task.yield() }
}
