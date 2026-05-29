import Foundation

struct MockAuthRepository: AuthRepository {
    func login(username: String, password: String) async throws -> AuthSession {
        try await Task.sleep(for: .milliseconds(300))
        return AuthSession(
            accessToken: "preview-token",
            refreshToken: "preview-refresh-token",
            user: AppUser(
                id: 1,
                username: username,
                email: "emily.johnson@x.dummyjson.com",
                firstName: "Emily",
                lastName: "Johnson",
                imageURL: URL(string: "https://dummyjson.com/icon/emilys/128")
            )
        )
    }
}
