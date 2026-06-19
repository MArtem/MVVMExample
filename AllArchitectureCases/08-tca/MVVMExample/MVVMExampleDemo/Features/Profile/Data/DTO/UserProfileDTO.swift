import Foundation

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

struct CompanyDTO: Decodable {
    let title: String?
}
