import Foundation

/// Transport payload owned by the data/API boundary.
///
/// Mapping responsibility: keep backend optionality, naming, and wire-format quirks here so domain and presentation models stay transport-independent.
struct UpdateProfileDTO: Encodable {
    let firstName: String
    let lastName: String
    let email: String
}
