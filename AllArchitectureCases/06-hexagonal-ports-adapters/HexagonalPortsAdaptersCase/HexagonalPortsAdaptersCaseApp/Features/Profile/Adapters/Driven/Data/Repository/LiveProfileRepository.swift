import Foundation

/// Live profile repository backed by the configured API client.
///
/// Side effects:
/// Performs authenticated profile requests and maps transport DTOs into `UserProfile`.
struct LiveProfileRepository: ProfileRepository {
    private let apiClient: APIClient
    private let mapper: ProfileDTOMapper

    init(apiClient: APIClient, mapper: ProfileDTOMapper = ProfileDTOMapper()) {
        self.apiClient = apiClient
        self.mapper = mapper
    }

    func loadCurrentProfile(session: AuthSession) async throws -> UserProfile {
        let response: UserProfileDTO = try await apiClient.send(
            CurrentUserRequest(accessToken: session.accessToken)
        )
        return try mapper.map(response)
    }

    func updateProfile(id: UserProfile.ID, request: UpdateProfileRequest) async throws -> UserProfile {
        let response: UserProfileDTO = try await apiClient.send(
            UpdateUserRequest(id: id, request: request)
        )
        return try mapper.map(response)
    }
}
