import Foundation
import Observation

/// MVP passive view presenter for the login screen.
///
/// Ownership:
/// Created by the auth screen composition layer for one login flow.
///
/// MVP boundary:
/// This presenter owns login presentation decisions, form state, validation, the login task, and the success callback. The SwiftUI screen stays passive by rendering state and forwarding user intents.
@MainActor
@Observable
final class LoginPresenter {
    typealias State = LoginViewState

    var username: String = ""
    var password: String = ""
    private(set) var state: State

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

    /// Starts user-requested authentication.
    func loginTapped() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        login(username: trimmedUsername, password: password)
    }

    /// Applies approved demo credentials to the editable form.
    func useDemoCredentialsTapped() {
        guard let demoCredentials else { return }
        username = demoCredentials.username
        password = demoCredentials.password
        state.errorMessage = nil
    }

    func clearError() {
        state.errorMessage = nil
    }

    private func login(username: String, password: String) {
        loginTask?.cancel()
        state.isLoading = true
        state.errorMessage = nil

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
