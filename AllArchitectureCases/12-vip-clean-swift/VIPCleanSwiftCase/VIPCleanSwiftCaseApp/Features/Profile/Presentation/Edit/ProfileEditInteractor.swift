import Foundation
import Observation

/// Owns editable profile form state and save/cancel intents.
///
/// Ownership:
/// Created by the profile edit route for a single edit transaction.
///
/// Behavior:
/// The form preserves first and last names separately and sends trimmed values only when the user saves.
@MainActor
@Observable
final class ProfileEditInteractor {
    var firstName: String
    var lastName: String
    var email: String
    private(set) var state = ProfileEditViewState()

    private let payload: ProfileEditRoutePayload
    private let worker: ProfileEditWorker
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
        self.worker = ProfileEditWorker(repository: repository)
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
    ///
    /// Concurrency:
    /// A new save request cancels any in-flight save task owned by this Interactor.
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

        saveTask = Task { [worker, payload, onSaveSuccess] in
            do {
                let updatedProfile = try await worker.updateProfile(id: payload.id, request: request)
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


/// Clean Swift Worker for profile-edit mutation I/O.
@MainActor
struct ProfileEditWorker {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func updateProfile(id: UserProfile.ID, request: UpdateProfileRequest) async throws -> UserProfile {
        try await repository.updateProfile(id: id, request: request)
    }
}
