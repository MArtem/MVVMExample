import Testing
@testable import CleanLayeredCase

@MainActor
@Suite("Login ViewModel tests")
struct LoginViewModelTests {
    @Test("Demo credentials populate form only when configured")
    func demoCredentialsPopulateFormOnlyWhenConfigured() {
        let hiddenViewModel = LoginViewModel(repository: ControllableAuthRepository(), demoCredentials: nil, onLoginSuccess: { _ in })
        hiddenViewModel.useDemoCredentialsTapped()
        #expect(hiddenViewModel.username == "")
        #expect(hiddenViewModel.password == "")
        #expect(hiddenViewModel.state.showsDemoCredentialsButton == false)

        let shownViewModel = LoginViewModel(
            repository: ControllableAuthRepository(),
            demoCredentials: DemoCredentials(username: "demo-user", password: "demo-pass"),
            onLoginSuccess: { _ in }
        )
        shownViewModel.useDemoCredentialsTapped()
        #expect(shownViewModel.username == "demo-user")
        #expect(shownViewModel.password == "demo-pass")
        #expect(shownViewModel.state.showsDemoCredentialsButton == true)
    }

    @Test("Login success trims username, keeps password as entered, and publishes session")
    func loginSuccessTrimsUsernameKeepsPasswordAndPublishesSession() async {
        let repository = ControllableAuthRepository()
        var receivedSession: AuthSession?
        let viewModel = LoginViewModel(repository: repository, onLoginSuccess: { receivedSession = $0 })
        viewModel.username = "  ada  "
        viewModel.password = "  secret  "

        viewModel.loginTapped()
        let call = await repository.waitForLoginCall(at: 0)
        await repository.waitForLoginContinuation(at: 0)

        #expect(viewModel.state.isLoading == true)
        #expect(call.username == "ada")
        #expect(call.password == "  secret  ")

        let session = makeLoginSession()
        await repository.completeLogin(at: 0, with: .success(session))
        await drainLoginMainActorTasks()

        #expect(viewModel.state.isLoading == false)
        #expect(viewModel.state.errorMessage == nil)
        #expect(receivedSession == session)
    }

    @Test("Login failure maps to user-safe error and does not publish session")
    func loginFailureMapsToUserSafeErrorAndDoesNotPublishSession() async {
        let repository = ControllableAuthRepository()
        var successCount = 0
        let viewModel = LoginViewModel(repository: repository, onLoginSuccess: { _ in successCount += 1 })
        viewModel.username = "ada"
        viewModel.password = "wrong"

        viewModel.loginTapped()
        _ = await repository.waitForLoginCall(at: 0)
        await repository.waitForLoginContinuation(at: 0)
        await repository.completeLogin(at: 0, with: .failure(AppAPIError.unauthorized("technical auth failure")))
        await drainLoginMainActorTasks()

        #expect(viewModel.state.isLoading == false)
        #expect(viewModel.state.errorMessage == "Your session expired. Please sign in again.")
        #expect(successCount == 0)
    }
}

private struct LoginCall: Equatable {
    let username: String
    let password: String
}

private actor ControllableAuthRepository: AuthRepository {
    private var loginCalls: [LoginCall] = []
    private var loginContinuations: [Int: CheckedContinuation<AuthSession, Error>] = [:]
    private var loginWaiters: [Int: CheckedContinuation<LoginCall, Never>] = [:]
    private var loginContinuationWaiters: [Int: CheckedContinuation<Void, Never>] = [:]

    func login(username: String, password: String) async throws -> AuthSession {
        let index = loginCalls.count
        let call = LoginCall(username: username, password: password)
        loginCalls.append(call)
        loginWaiters.removeValue(forKey: index)?.resume(returning: call)
        return try await withCheckedThrowingContinuation { continuation in
            loginContinuations[index] = continuation
            loginContinuationWaiters.removeValue(forKey: index)?.resume()
        }
    }

    func waitForLoginCall(at index: Int) async -> LoginCall {
        if loginCalls.indices.contains(index) { return loginCalls[index] }
        return await withCheckedContinuation { loginWaiters[index] = $0 }
    }

    func waitForLoginContinuation(at index: Int) async {
        if loginContinuations[index] != nil { return }
        await withCheckedContinuation { loginContinuationWaiters[index] = $0 }
    }

    func completeLogin(at index: Int, with result: Result<AuthSession, Error>) {
        loginContinuations.removeValue(forKey: index)?.resume(with: result)
    }
}

private func makeLoginSession() -> AuthSession {
    AuthSession(
        accessToken: "demo-access-credential-not-a-secret",
        refreshToken: "demo-refresh-credential-not-a-secret",
        user: AppUser(
            id: 7,
            username: "ada",
            email: "ada@example.com",
            firstName: "Ada",
            lastName: "Lovelace",
            imageURL: nil
        )
    )
}

@MainActor
private func drainLoginMainActorTasks() async {
    for _ in 0..<10 { await Task.yield() }
}
