import Foundation
import Observation

/// MVP passive view presenter for the profile screen.
///
/// Ownership:
/// Created by the profile screen composition layer for the authenticated session.
///
/// MVP boundary:
/// This presenter owns profile presentation decisions, loading, routing callbacks, and logout forwarding. The SwiftUI view remains passive and only renders `state` plus forwards user intents.
@MainActor
@Observable
final class ProfilePresenter {
    typealias State = ProfileViewState

    private(set) var state: State = .loading

    private let session: AuthSession
    private let repository: ProfileRepository
    private let viewStateBuilder: ProfileViewStateBuilder
    private weak var router: ProfileRouter?
    private let onLogout: () -> Void
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    private var loadGeneration = 0

    init(
        session: AuthSession,
        repository: ProfileRepository,
        router: ProfileRouter,
        viewStateBuilder: ProfileViewStateBuilder = ProfileViewStateBuilder(),
        onLogout: @escaping () -> Void
    ) {
        self.session = session
        self.repository = repository
        self.router = router
        self.viewStateBuilder = viewStateBuilder
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
    func profileUpdated(_ profile: UserProfile) {
        state = .content(viewStateBuilder.makeContent(from: profile))
    }

    /// Requests logout through the app-level session owner.
    func logoutTapped() {
        onLogout()
    }

    private func load() {
        loadTask?.cancel()
        loadGeneration += 1
        let generation = loadGeneration
        state = .loading

        loadTask = Task { [repository, session, viewStateBuilder] in
            do {
                let profile = try await repository.loadCurrentProfile(session: session)
                try Task.checkCancellation()
                guard generation == loadGeneration else { return }
                state = .content(viewStateBuilder.makeContent(from: profile))
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                guard generation == loadGeneration else { return }
                state = .error(viewStateBuilder.makeError(from: error))
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
