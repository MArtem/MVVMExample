import Foundation

struct LiveAuthRepository: AuthRepository {
    private let apiClient: APIClient
    private let mapper: AuthMapper

    init(apiClient: APIClient, mapper: AuthMapper = AuthMapper()) {
        self.apiClient = apiClient
        self.mapper = mapper
    }

    func login(username: String, password: String) async throws -> AuthSession {
        let response: AuthUserDTO = try await apiClient.send(
            LoginAPIRequest(username: username, password: password)
        )
        return mapper.map(response)
    }
}
