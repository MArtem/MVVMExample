import Foundation

struct AuthSession: Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let user: AppUser
}

struct AppUser: Identifiable, Equatable, Sendable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let imageURL: URL?

    var displayName: String {
        var components = PersonNameComponents()
        components.givenName = firstName
        components.familyName = lastName
        return PersonNameComponentsFormatter.localizedString(from: components, style: .medium)
    }
}
