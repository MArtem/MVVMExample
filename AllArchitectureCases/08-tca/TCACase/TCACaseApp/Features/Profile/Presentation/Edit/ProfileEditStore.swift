import Foundation
import Observation

/// TCA semantic note:
/// The public `state` remains the rendered view state for SwiftUI compatibility, while feature-local `FeatureState` keeps non-rendered domain/cache/form state explicit so effects and reducers do not hide state-machine data in anonymous fields.
///
/// Owns editable profile form state and save/cancel intents.
///
/// Ownership:
/// Created by the profile edit route for a single edit transaction.
///
/// Behavior:
/// The form preserves first and last names separately and sends trimmed values only when the user saves.
@MainActor
@Observable
final class ProfileEditStore {
    struct FeatureState: Equatable {
        var draft: UpdateProfileRequest
    }

    typealias State = ProfileEditViewState

    /// Enum contract for a local app boundary.
    ///
    /// Document ownership and side effects here when this type grows beyond value-only data.
    private enum Action {
        case saveTapped
        case cancelTapped
        case clearError
    }

    /// Enum contract for a local app boundary.
    ///
    /// Document ownership and side effects here when this type grows beyond value-only data.
    private enum Effect {
        case save(UpdateProfileRequest)
    }

    /// Enum contract for a local app boundary.
    ///
    /// Document ownership and side effects here when this type grows beyond value-only data.
    private enum StateMutation {
        case setSaving(Bool)
        case setError(String?)
    }

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
    ///
    /// Concurrency:
    /// A new save request cancels any in-flight save task owned by this Store.
    func saveTapped() {
        handle(.saveTapped)
    }

    func cancelTapped() {
        handle(.cancelTapped)
    }

    func clearError() {
        handle(.clearError)
    }

    private func handle(_ action: Action) {
        switch action {
        case .saveTapped:
            let request = UpdateProfileRequest(
                firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            run(.save(request))
        case .cancelTapped:
            router?.pop()
        case .clearError:
            reduce(.setError(nil))
        }
    }

    private func reduce(_ mutation: StateMutation) {
        switch mutation {
        case .setSaving(let isSaving):
            state.isSaving = isSaving
        case .setError(let message):
            state.errorMessage = message
        }
    }

    private func run(_ effect: Effect) {
        switch effect {
        case .save(let request):
            save(request: request)
        }
    }

    private func save(request: UpdateProfileRequest) {
        saveTask?.cancel()
        reduce(.setSaving(true))
        reduce(.setError(nil))

        saveTask = Task { [repository, payload] in
            do {
                let updatedProfile = try await repository.updateProfile(id: payload.id, request: request)
                try Task.checkCancellation()
                reduce(.setSaving(false))
                onSaveSuccess(updatedProfile)
                router?.pop()
            } catch is CancellationError {
                return
            } catch AppAPIError.cancelled {
                return
            } catch {
                reduce(.setSaving(false))
                reduce(.setError(AppErrorMapper.userMessage(for: error)))
            }
        }
    }
}
