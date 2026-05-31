import Foundation
import Observation
import AppErrors

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
    @ObservationIgnored private var saveTask: Task<Void, Never>?

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

    deinit {
        saveTask?.cancel()
    }

    func saveTapped() {
        save()
    }

    func cancelTapped() {
        router?.pop()
    }

    func clearError() {
        state.errorMessage = nil
    }

    private func save() {
        saveTask?.cancel()
        state.isSaving = true
        state.errorMessage = nil

        let request = UpdateProfileRequest(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        saveTask = Task { [repository, payload] in
            do {
                _ = try await repository.updateProfile(id: payload.id, request: request)
                try Task.checkCancellation()
                state.isSaving = false
                router?.pop()
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                state.isSaving = false
                state.errorMessage = error.localizedDescription
            }
        }
    }
}
