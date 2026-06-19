import Foundation

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
