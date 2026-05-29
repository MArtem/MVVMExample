import Foundation

struct LoginAPIRequest: APIRequest {
    let username: String
    let password: String

    let path = "/auth/login"
    let method: HTTPMethod = .post

    var body: Data? {
        JSONBodyEncoder.encode(
            LoginRequestDTO(
                username: username,
                password: password,
                expiresInMins: 30
            )
        )
    }
}
