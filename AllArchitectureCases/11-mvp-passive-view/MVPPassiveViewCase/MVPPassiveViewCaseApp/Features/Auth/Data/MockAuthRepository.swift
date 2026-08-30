import Foundation

#if DEBUG
/// Preview/demo authentication repository.
///
/// Important:
/// This must stay outside production runtime wiring unless explicitly selected by a debug/demo configuration.
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
