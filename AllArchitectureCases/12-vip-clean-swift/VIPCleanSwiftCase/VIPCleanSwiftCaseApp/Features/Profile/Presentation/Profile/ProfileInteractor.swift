import Foundation
import Observation

/// Owns profile screen state and profile-level user intents.
///
/// Ownership:
/// Created by the profile screen composition layer for the authenticated session.
///
/// Behavior:
/// Loading is cancellable and stale responses are ignored; logout is delegated to the app/session owner.
@MainActor
@Observable
final class ProfileInteractor {
    private(set) var state: ProfileViewState = .loading

    private let session: AuthSession
    private let worker: ProfileWorker
    private let presenter: ProfilePresenter
    private weak var router: ProfileRouter?
    private let onLogout: () -> Void
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    private var loadGeneration = 0

    init(
        session: AuthSession,
        repository: ProfileRepository,
        router: ProfileRouter,
        presenter: ProfilePresenter = ProfilePresenter(),
        onLogout: @escaping () -> Void
    ) {
        self.session = session
        self.worker = ProfileWorker(session: session, repository: repository)
        self.router = router
        self.presenter = presenter
        self.onLogout = onLogout
    }

    deinit {
        loadTask?.cancel()
    }

    func appeared() {
        load()
    }

    func retryTapped() {
        load()
    }

    func editTapped() {
        openEdit()
    }

    /// Applies a profile returned by the edit flow without forcing another network read.
    ///
    /// External usage:
    /// Called by the profile navigation composition after `ProfileEditInteractor` saves successfully.
    func profileUpdated(_ profile: UserProfile) {
        state = .content(presenter.makeContent(from: profile))
    }

    /// Requests logout through the app-level session owner.
    ///
    /// Side effects:
    /// This Interactor does not clear the session store directly; app coordination owns that transition.
    func logoutTapped() {
        onLogout()
    }

    private func load() {
        loadTask?.cancel()
        loadGeneration += 1
        let generation = loadGeneration
        state = .loading

        loadTask = Task { [worker, presenter] in
            do {
                let profile = try await worker.loadCurrentProfile()
                try Task.checkCancellation()
                guard generation == loadGeneration else { return }
                state = .content(presenter.makeContent(from: profile))
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                guard generation == loadGeneration else { return }
                state = .error(presenter.makeError(from: error))
            }
        }
    }

    private func openEdit() {
        guard case .content(let content) = state else { return }
        router?.openEdit(
            ProfileEditRoutePayload(
                id: content.id,
                firstName: content.firstName,
                lastName: content.lastName,
                email: content.emailText
            )
        )
    }
}


/// Clean Swift Worker for profile loading I/O.
///
/// Keeps repository/session access out of the interactor's presentation state machine.
@MainActor
struct ProfileWorker {
    private let session: AuthSession
    private let repository: ProfileRepository

    init(session: AuthSession, repository: ProfileRepository) {
        self.session = session
        self.repository = repository
    }

    func loadCurrentProfile() async throws -> UserProfile {
        try await repository.loadCurrentProfile(session: session)
    }
}
