import Foundation
import Observation

@MainActor
@Observable
final class ProfileEditViewModel {
    var firstName: String
    var lastName: String
    var email: String
    private(set) var state = ProfileEditViewState()

    private let payload: ProfileEditRoutePayload
    private let repository: ProfileRepository
    private weak var router: ProfileRouter?
    private var task: Task<Void, Never>?

    init(
        payload: ProfileEditRoutePayload,
        repository: ProfileRepository,
        router: ProfileRouter
    ) {
        self.payload = payload
        self.repository = repository
        self.router = router
        self.firstName = payload.firstName
        self.lastName = payload.lastName
        self.email = payload.email
    }

    func send(_ action: ProfileEditAction) {
        switch action {
        case .saveTapped:
            save()
        case .cancelTapped:
            router?.pop()
        case .clearError:
            state.errorMessage = nil
        }
    }

    private func save() {
        task?.cancel()
        state.isSaving = true
        state.errorMessage = nil

        let request = UpdateProfileRequest(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        task = Task {
            do {
                try await Task.sleep(for: .milliseconds(350))
                _ = try await repository.updateProfile(id: payload.id, request: request)
                try Task.checkCancellation()
                state.isSaving = false
                router?.pop()
            } catch is CancellationError {
                return
            } catch {
                state.isSaving = false
                state.errorMessage = error.localizedDescription
            }
        }
    }
}
