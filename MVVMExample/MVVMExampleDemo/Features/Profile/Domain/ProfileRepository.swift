import Foundation

/// Profile feature data boundary.
///
/// Responsibilities:
/// - load and update user profile domain models;
/// - keep API DTOs and auth transport details outside presentation code.
protocol ProfileRepository {
    func loadCurrentProfile(session: AuthSession) async throws -> UserProfile
    func updateProfile(id: UserProfile.ID, request: UpdateProfileRequest) async throws -> UserProfile
}
