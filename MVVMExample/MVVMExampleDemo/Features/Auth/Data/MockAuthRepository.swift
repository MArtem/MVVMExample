import Foundation

#if DEBUG
struct MockAuthRepository: AuthRepository {
    func login(username: String, password: String) async throws -> AuthSession {
        AuthSession(
            accessToken: "demo-access-credential-not-a-secret",
            refreshToken: "demo-refresh-credential-not-a-secret",
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
#endif
