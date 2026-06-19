import Foundation
import SwiftData

/// Durable local profile override store.
///
/// Source-of-truth policy:
/// The server response remains preferred when available, then app-local edits are overlaid so demo/non-persistent backend behavior does not discard user changes after relaunch.
@MainActor
final class ProfileLocalStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func profile(id: UserProfile.ID) -> UserProfile? {
        persistedProfile(id: id)?.makeProfile()
    }

    func merge(remoteProfile: UserProfile) -> UserProfile {
        profile(id: remoteProfile.id) ?? remoteProfile
    }

    func save(_ profile: UserProfile) {
        if let existing = persistedProfile(id: profile.id) {
            existing.update(from: profile)
        } else {
            modelContext.insert(PersistedUserProfile(profile: profile))
        }
        try? modelContext.save()
    }

    func saveLocalUpdate(id: UserProfile.ID, request: UpdateProfileRequest) -> UserProfile? {
        guard let existing = profile(id: id) else { return nil }
        let updated = UserProfile(
            id: existing.id,
            username: existing.username,
            email: request.email,
            firstName: request.firstName,
            lastName: request.lastName,
            phone: existing.phone,
            imageURL: existing.imageURL,
            companyTitle: existing.companyTitle
        )
        save(updated)
        return updated
    }

    private func persistedProfile(id: UserProfile.ID) -> PersistedUserProfile? {
        let key = PersistedUserProfile.key(id: id)
        var descriptor = FetchDescriptor<PersistedUserProfile>(
            predicate: #Predicate { $0.key == key }
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }
}

/// Profile repository decorator that makes local SwiftData edits durable when the current backend does not persist them reliably.
struct OfflineProfileRepository: ProfileRepository {
    private let remote: ProfileRepository
    private let localStore: ProfileLocalStore

    init(remote: ProfileRepository, localStore: ProfileLocalStore) {
        self.remote = remote
        self.localStore = localStore
    }

    func loadCurrentProfile(session: AuthSession) async throws -> UserProfile {
        do {
            let remoteProfile = try await remote.loadCurrentProfile(session: session)
            return await localStore.merge(remoteProfile: remoteProfile)
        } catch {
            if let localProfile = await localStore.profile(id: session.user.id) {
                return localProfile
            }
            throw error
        }
    }

    func updateProfile(id: UserProfile.ID, request: UpdateProfileRequest) async throws -> UserProfile {
        do {
            let updated = try await remote.updateProfile(id: id, request: request)
            await localStore.save(updated)
            return updated
        } catch {
            if let localProfile = await localStore.saveLocalUpdate(id: id, request: request) {
                return localProfile
            }
            throw error
        }
    }
}
