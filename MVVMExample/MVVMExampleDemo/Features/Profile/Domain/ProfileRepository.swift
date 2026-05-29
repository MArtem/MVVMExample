import Foundation

protocol ProfileRepository {
    func loadCurrentProfile(session: AuthSession) async throws -> UserProfile
    func updateProfile(id: UserProfile.ID, request: UpdateProfileRequest) async throws -> UserProfile
}
