import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    private(set) var state: ProfileViewState = .loading

    private let session: AuthSession
    private let repository: ProfileRepository
    private let viewStateBuilder: ProfileViewStateBuilder
    private weak var router: ProfileRouter?
    private let onLogout: () -> Void
    private var task: Task<Void, Never>?

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

    func send(_ action: ProfileAction) {
        switch action {
        case .appeared:
            load()
        case .retryTapped:
            load()
        case .editTapped:
            openEdit()
        case .logoutTapped:
            onLogout()
        }
    }

    private func load() {
        task?.cancel()
        state = .loading

        task = Task {
            do {
                let profile = try await repository.loadCurrentProfile(session: session)
                try Task.checkCancellation()
                state = .content(viewStateBuilder.makeContent(from: profile))
            } catch is CancellationError {
                return
            } catch {
                state = .error(viewStateBuilder.makeError(from: error))
            }
        }
    }

    private func openEdit() {
        guard case .content(let content) = state else { return }
        router?.openEdit(
            ProfileEditRoutePayload(
                id: content.id,
                firstName: content.displayName.components(separatedBy: " ").first ?? "",
                lastName: content.displayName.components(separatedBy: " ").dropFirst().joined(separator: " "),
                email: content.emailText
            )
        )
    }
}
