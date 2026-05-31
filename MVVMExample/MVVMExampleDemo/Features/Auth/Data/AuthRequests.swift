import Foundation

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
