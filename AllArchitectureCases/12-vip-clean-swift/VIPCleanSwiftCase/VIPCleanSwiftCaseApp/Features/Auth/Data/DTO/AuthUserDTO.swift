import Foundation

/// Transport payload owned by the data/API boundary.
///
/// Mapping responsibility: keep backend optionality, naming, and wire-format quirks here so domain and presentation models stay transport-independent.
struct AuthUserDTO: Decodable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let image: String?
    let accessToken: String
    let refreshToken: String
}
