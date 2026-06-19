import Foundation

/// Authenticated current-user profile request.
///
/// Security boundary:
/// The bearer token is a transport header and must be redacted by logging infrastructure.
struct CurrentUserRequest: APIRequest {
    let accessToken: String

    let path = "/auth/me"
    let method: HTTPMethod = .get

    var headers: [String: String] {
        ["Authorization": "Bearer \(accessToken)"]
    }
}

/// Profile update request for editable profile fields currently supported by the app.
struct UpdateUserRequest: APIRequest {
    let id: Int
    let request: UpdateProfileRequest

    var path: String { "/users/\(id)" }
    let method: HTTPMethod = .patch

    func makeBody() throws -> Data? {
        try JSONBodyEncoder.encode(
            UpdateProfileDTO(
                firstName: request.firstName,
                lastName: request.lastName,
                email: request.email
            )
        )
    }
}
