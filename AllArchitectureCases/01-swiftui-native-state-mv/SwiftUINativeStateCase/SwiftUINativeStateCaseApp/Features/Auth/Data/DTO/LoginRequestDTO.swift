import Foundation

/// Transport payload owned by the data/API boundary.
///
/// Mapping responsibility: keep backend optionality, naming, and wire-format quirks here so domain and presentation models stay transport-independent.
struct LoginRequestDTO: Encodable {
    let username: String
    let password: String
    let expiresInMins: Int
}
