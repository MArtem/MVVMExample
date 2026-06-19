import Foundation
import SwiftData

/// SwiftData schema and container factory for durable non-secret app-local state.
///
/// Security boundary:
/// Token-like session credentials are intentionally not part of this schema; they are stored through Keychain-backed session storage.
enum AppPersistence {
    static let schema = Schema([
        PersistedArticleInteraction.self,
        PersistedUserProfile.self
    ])

    @MainActor
    static func makeModelContainer(inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

@Model
final class PersistedArticleInteraction {
    @Attribute(.unique) var key: String
    var userID: Int
    var articleID: Int
    var isLiked: Bool
    var likesCount: Int
    var updatedAt: Date

    init(userID: Int, articleID: Int, isLiked: Bool, likesCount: Int, updatedAt: Date = Date()) {
        self.key = Self.key(userID: userID, articleID: articleID)
        self.userID = userID
        self.articleID = articleID
        self.isLiked = isLiked
        self.likesCount = max(0, likesCount)
        self.updatedAt = updatedAt
    }

    static func key(userID: Int, articleID: Int) -> String {
        "\(userID):\(articleID)"
    }
}

@Model
final class PersistedUserProfile {
    @Attribute(.unique) var key: String
    var id: Int
    var username: String
    var email: String
    var firstName: String
    var lastName: String
    var phone: String?
    var imageURLString: String?
    var companyTitle: String?
    var updatedAt: Date

    init(profile: UserProfile, updatedAt: Date = Date()) {
        self.key = Self.key(id: profile.id)
        self.id = profile.id
        self.username = profile.username
        self.email = profile.email
        self.firstName = profile.firstName
        self.lastName = profile.lastName
        self.phone = profile.phone
        self.imageURLString = profile.imageURL?.absoluteString
        self.companyTitle = profile.companyTitle
        self.updatedAt = updatedAt
    }

    static func key(id: Int) -> String {
        "profile:\(id)"
    }

    func update(from profile: UserProfile) {
        username = profile.username
        email = profile.email
        firstName = profile.firstName
        lastName = profile.lastName
        phone = profile.phone
        imageURLString = profile.imageURL?.absoluteString
        companyTitle = profile.companyTitle
        updatedAt = Date()
    }

    func makeProfile() -> UserProfile {
        UserProfile(
            id: id,
            username: username,
            email: email,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            imageURL: imageURLString.flatMap(URL.init(string:)),
            companyTitle: companyTitle
        )
    }
}
