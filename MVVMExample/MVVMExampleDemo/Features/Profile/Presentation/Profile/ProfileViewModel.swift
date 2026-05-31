import Foundation
import Observation
import AppErrors

@MainActor
@Observable
final class ProfileViewModel {
    private(set) var state: ProfileViewState = .loading

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
