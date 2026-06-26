import Foundation

/// Domain model used across feature boundaries.
///
/// Keep this type focused on product meaning; transport, persistence, and presentation-only formatting belong in adapters/builders.
struct UserProfile: Identifiable, Equatable, Sendable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let phone: String?
    let imageURL: URL?
    let companyTitle: String?

    var displayName: String {
        var components = PersonNameComponents()
        components.givenName = firstName
        components.familyName = lastName
        return PersonNameComponentsFormatter.localizedString(from: components, style: .medium)
    }
}

/// API request description for the network adapter layer.
///
/// Boundary rule: encode transport path, method, headers, and body here; callers should pass domain intent, not URLSession details.
struct UpdateProfileRequest: Codable, Equatable, Sendable {
    let firstName: String
    let lastName: String
    let email: String
}
