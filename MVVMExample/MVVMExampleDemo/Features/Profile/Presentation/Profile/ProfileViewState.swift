import Foundation

enum ProfileViewState: Equatable {
    case loading
    case content(ProfileContentViewState)
    case error(MessageViewState)
}

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
