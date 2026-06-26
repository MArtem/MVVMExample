import Foundation

/// Transport payload owned by the data/API boundary.
///
/// Mapping responsibility: keep backend optionality, naming, and wire-format quirks here so domain and presentation models stay transport-independent.
struct UserProfileDTO: Decodable {
    let id: Int?
    let username: String?
    let email: String?
    let firstName: String?
    let lastName: String?
    let phone: String?
    let image: String?
    let company: CompanyDTO?
}

/// Transport payload owned by the data/API boundary.
///
/// Mapping responsibility: keep backend optionality, naming, and wire-format quirks here so domain and presentation models stay transport-independent.
struct CompanyDTO: Decodable {
    let title: String?
}
