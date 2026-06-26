import Foundation

/// Render-ready presentation state consumed by SwiftUI views.
///
/// Formatting policy: expensive localization, date, number, and accessibility strings should be prepared before row/body rendering hot paths.
enum ProfileViewState: Equatable {
    case loading
    case content(ProfileContentViewState)
    case error(MessageViewState)
}

/// Render-ready presentation state consumed by SwiftUI views.
///
/// Formatting policy: expensive localization, date, number, and accessibility strings should be prepared before row/body rendering hot paths.
struct ProfileContentViewState: Equatable {
    let id: Int
    let firstName: String
    let lastName: String
    let displayName: String
    let usernameText: String
    let emailText: String
    let phoneText: String
    let companyText: String
    let imageURL: URL?
}
