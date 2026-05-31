import Foundation
import Observation
import AppConfiguration
import AppErrors
import AppLocalization

@MainActor
@Observable
final class LoginViewModel {
    var username: String = ""
    var password: String = ""
    private(set) var state: LoginViewState

    private let repository: AuthRepository
    private let demoCredentials: DemoCredentials?
    private let onLoginSuccess: (AuthSession) -> Void
    @ObservationIgnored private var loginTask: Task<Void, Never>?

    init(
        repository: AuthRepository,
        demoCredentials: DemoCredentials? = nil,
        onLoginSuccess: @escaping (AuthSession) -> Void
    ) {
        self.repository = repository
        self.demoCredentials = demoCredentials
        self.onLoginSuccess = onLoginSuccess
        self.state = LoginViewState(
            showsDemoCredentialsButton: demoCredentials != nil
        )
    }

    deinit {
        loginTask?.cancel()
    }

    func loginTapped() {
        login()
    }

    func useDemoCredentialsTapped() {
        guard let demoCredentials else { return }
        username = demoCredentials.username
        password = demoCredentials.password
        state.errorMessage = nil
    }

    func clearError() {
        state.errorMessage = nil
    }

    private func login() {
        loginTask?.cancel()
        state.isLoading = true
        state.errorMessage = nil

        let username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = password

        loginTask = Task { [repository, onLoginSuccess] in
            do {
                let session = try await repository.login(
                    username: username,
                    password: password
                )
                try Task.checkCancellation()
                state.isLoading = false
                onLoginSuccess(session)
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                state.isLoading = false
                state.errorMessage = AppErrorMapper.userMessage(for: error)
            }
        }
    }
}
