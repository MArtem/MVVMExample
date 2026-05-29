import Foundation

struct CurrentUserRequest: APIRequest {
    let accessToken: String

    let path = "/auth/me"
    let method: HTTPMethod = .get

    var headers: [String: String] {
        ["Authorization": "Bearer \(accessToken)"]
    }
}

struct UpdateUserRequest: APIRequest {
    let id: Int
    let request: UpdateProfileRequest

    var path: String { "/users/\(id)" }
    let method: HTTPMethod = .patch

    var body: Data? {
        JSONBodyEncoder.encode(
            UpdateProfileDTO(
                firstName: request.firstName,
                lastName: request.lastName,
                email: request.email
            )
        )
    }
}
