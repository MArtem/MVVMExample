import Foundation

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

struct UpdateProfileRequest: Equatable, Sendable {
    let firstName: String
    let lastName: String
    let email: String
}
