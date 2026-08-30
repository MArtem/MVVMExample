import Foundation
import Observation

/// Owns login presentation state and user intents.
///
/// Ownership:
/// Created by the auth screen composition layer for one login flow.
///
/// Behavior:
/// Login runs in a cancellable task, reports user-safe errors, and calls `onLoginSuccess` only after a non-cancelled session is returned.
@MainActor
@Observable
final class LoginPresenter {
    var username: String = ""
    var password: String = ""
    private(set) var state: LoginViewState

    private let interactor: LoginInteractor
    private let demoCredentials: DemoCredentials?
    private let onLoginSuccess: (AuthSession) -> Void
    @ObservationIgnored private var loginTask: Task<Void, Never>?

    init(
        interactor: LoginInteractor,
        demoCredentials: DemoCredentials? = nil,
        onLoginSuccess: @escaping (AuthSession) -> Void
    ) {
        self.interactor = interactor
        self.demoCredentials = demoCredentials
        self.onLoginSuccess = onLoginSuccess
        self.state = LoginViewState(
            showsDemoCredentialsButton: demoCredentials != nil
        )
    }

    deinit {
        loginTask?.cancel()
    }

    /// Starts user-requested authentication.
    ///
    /// External usage:
    /// Called from the login button intent.
    func loginTapped() {
        login()
    }

    /// Applies approved demo credentials to the editable form.
    ///
    /// Invariant:
    /// This is available only when the dependency graph provided demo credentials.
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

        loginTask = Task { [interactor, onLoginSuccess] in
            do {
                let session = try await interactor.login(
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


/// VIPER Interactor for the login module.
///
/// Owns authentication business work and keeps repository calls out of the presenter.
@MainActor
struct LoginInteractor {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func login(username: String, password: String) async throws -> AuthSession {
        try await repository.login(username: username, password: password)
    }
}
