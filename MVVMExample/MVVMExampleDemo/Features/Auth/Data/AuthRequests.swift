import Foundation

/// Login endpoint request.
///
/// Security boundary:
/// Credentials are encoded into the request body and must not be logged by callers.
struct LoginAPIRequest: APIRequest {
    let username: String
    let password: String

    let path = "/auth/login"
    let method: HTTPMethod = .post

    func makeBody() throws -> Data? {
        try JSONBodyEncoder.encode(
            LoginRequestDTO(
                username: username,
                password: password,
                expiresInMins: 30
            )
        )
    }
}
