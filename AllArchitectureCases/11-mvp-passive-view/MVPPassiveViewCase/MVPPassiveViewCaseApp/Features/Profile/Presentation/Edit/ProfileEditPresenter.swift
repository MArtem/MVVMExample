import Foundation
import Observation

/// MVP passive view presenter for the editable profile form.
///
/// Ownership:
/// Created by the profile edit route for a single edit transaction.
///
/// MVP boundary:
/// This presenter owns form presentation decisions, save/cancel handling, repository update orchestration, routing handoff, and save result propagation while the SwiftUI form stays render-forwarding.
@MainActor
@Observable
final class ProfileEditPresenter {
    typealias State = ProfileEditViewState

    var firstName: String
    var lastName: String
    var email: String
    private(set) var state = State()

    private let payload: ProfileEditRoutePayload
    private let repository: ProfileRepository
    private weak var router: ProfileRouter?
    private let onSaveSuccess: (UserProfile) -> Void
    @ObservationIgnored private var saveTask: Task<Void, Never>?

    init(
        payload: ProfileEditRoutePayload,
        repository: ProfileRepository,
        router: ProfileRouter,
        onSaveSuccess: @escaping (UserProfile) -> Void
    ) {
        self.payload = payload
        self.repository = repository
        self.router = router
        self.onSaveSuccess = onSaveSuccess
        self.firstName = payload.firstName
        self.lastName = payload.lastName
        self.email = payload.email
    }

    deinit {
        saveTask?.cancel()
    }

    /// Saves the current form values through the profile repository.
    func saveTapped() {
        let request = UpdateProfileRequest(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        save(request: request)
    }

    func cancelTapped() {
        router?.pop()
    }

    func clearError() {
        state.errorMessage = nil
    }

    private func save(request: UpdateProfileRequest) {
        saveTask?.cancel()
        state.isSaving = true
        state.errorMessage = nil

        saveTask = Task { [repository, payload] in
            do {
                let updatedProfile = try await repository.updateProfile(id: payload.id, request: request)
                try Task.checkCancellation()
                state.isSaving = false
                onSaveSuccess(updatedProfile)
                router?.pop()
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                state.isSaving = false
                state.errorMessage = AppErrorMapper.userMessage(for: error)
            }
        }
    }
}
