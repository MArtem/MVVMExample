import Foundation
import Observation

@MainActor
@Observable
final class LoginViewModel {
    var username: String = "emilys"
    var password: String = "emilyspass"
    private(set) var state = LoginViewState()

    private let repository: AuthRepository
    private let onLoginSuccess: (AuthSession) -> Void
    private var loginTask: Task<Void, Never>?

    init(
        repository: AuthRepository,
        onLoginSuccess: @escaping (AuthSession) -> Void
    ) {
        self.repository = repository
        self.onLoginSuccess = onLoginSuccess
    }

    func send(_ action: LoginAction) {
        switch action {
        case .loginTapped:
            login()

        case .useDemoCredentialsTapped:
            username = "emilys"
            password = "emilyspass"
            state.errorMessage = nil

        case .clearError:
            state.errorMessage = nil
        }
    }

    private func login() {
        loginTask?.cancel()
        state.isLoading = true
        state.errorMessage = nil

        let username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = password

        loginTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(450))
                let session = try await repository.login(
                    username: username,
                    password: password
                )
                try Task.checkCancellation()
                state.isLoading = false
                onLoginSuccess(session)
            } catch is CancellationError {
                return
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
            }
        }
    }
}
