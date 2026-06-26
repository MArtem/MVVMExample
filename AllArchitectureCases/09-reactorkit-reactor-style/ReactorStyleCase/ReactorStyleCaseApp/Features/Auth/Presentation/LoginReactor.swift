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
final class LoginReactor {
    typealias State = LoginViewState

    /// Enum contract for a local app boundary.
    ///
    /// Document ownership and side effects here when this type grows beyond value-only data.
    private enum Action {
        case loginTapped
        case useDemoCredentialsTapped
        case clearError
    }

    /// Enum contract for a local app boundary.
    ///
    /// Document ownership and side effects here when this type grows beyond value-only data.
    private enum SideEffect {
        case login(username: String, password: String)
    }

    /// Enum contract for a local app boundary.
    ///
    /// Document ownership and side effects here when this type grows beyond value-only data.
    private enum Mutation {
        case setCredentials(username: String, password: String)
        case setLoading(Bool)
        case setError(String?)
    }

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
    ///
    /// External usage:
    /// Called from the login button intent.
    func loginTapped() {
        mutate(.loginTapped)
    }

    /// Applies approved demo credentials to the editable form.
    ///
    /// Invariant:
    /// This is available only when the dependency graph provided demo credentials.
    func useDemoCredentialsTapped() {
        mutate(.useDemoCredentialsTapped)
    }

    func clearError() {
        mutate(.clearError)
    }

    private func mutate(_ action: Action) {
        switch action {
        case .loginTapped:
            let username = username.trimmingCharacters(in: .whitespacesAndNewlines)
            run(.login(username: username, password: password))
        case .useDemoCredentialsTapped:
            guard let demoCredentials else { return }
            reduce(.setCredentials(username: demoCredentials.username, password: demoCredentials.password))
            reduce(.setError(nil))
        case .clearError:
            reduce(.setError(nil))
        }
    }

    private func reduce(_ mutation: Mutation) {
        switch mutation {
        case .setCredentials(let username, let password):
            self.username = username
            self.password = password
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        case .setError(let message):
            state.errorMessage = message
        }
    }

    private func run(_ effect: SideEffect) {
        switch effect {
        case .login(let username, let password):
            login(username: username, password: password)
        }
    }

    private func login(username: String, password: String) {
        loginTask?.cancel()
        reduce(.setLoading(true))
        reduce(.setError(nil))

        loginTask = Task { [repository, onLoginSuccess] in
            do {
                let session = try await repository.login(
                    username: username,
                    password: password
                )
                try Task.checkCancellation()
                reduce(.setLoading(false))
                onLoginSuccess(session)
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                reduce(.setLoading(false))
                reduce(.setError(AppErrorMapper.userMessage(for: error)))
            }
        }
    }
}
