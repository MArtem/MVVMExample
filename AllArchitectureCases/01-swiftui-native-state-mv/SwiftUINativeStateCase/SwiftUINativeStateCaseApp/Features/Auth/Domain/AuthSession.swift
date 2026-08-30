import Foundation

/// Domain model used across feature boundaries.
///
/// Keep this type focused on product meaning; transport, persistence, and presentation-only formatting belong in adapters/builders.
struct AuthSession: Codable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let user: AppUser
}

/// Domain model used across feature boundaries.
///
/// Keep this type focused on product meaning; transport, persistence, and presentation-only formatting belong in adapters/builders.
struct AppUser: Codable, Identifiable, Equatable, Sendable {
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
