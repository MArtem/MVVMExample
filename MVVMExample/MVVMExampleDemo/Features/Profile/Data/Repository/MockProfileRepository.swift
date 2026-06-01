import Foundation

/// Preview/demo profile repository with deterministic profile data.
///
/// Important:
/// This repository must not be wired into production runtime without an explicit debug/demo policy.
struct MockProfileRepository: ProfileRepository {
    func loadCurrentProfile(session: AuthSession) async throws -> UserProfile {
        try await Task.sleep(for: .milliseconds(250))
        return .fixture
    }

    func updateProfile(id: UserProfile.ID, request: UpdateProfileRequest) async throws -> UserProfile {
        try await Task.sleep(for: .milliseconds(250))
        return UserProfile(
            id: id,
            username: "emilys",
            email: request.email,
            firstName: request.firstName,
            lastName: request.lastName,
            phone: "+81 965-431-3024",
            imageURL: URL(string: "https://dummyjson.com/icon/emilys/128"),
            companyTitle: "Sales Manager"
        )
    }
}

extension UserProfile {
    static let fixture = UserProfile(
        id: 1,
        username: "emilys",
        email: "emily.johnson@x.dummyjson.com",
        firstName: "Emily",
        lastName: "Johnson",
        phone: "+81 965-431-3024",
        imageURL: URL(string: "https://dummyjson.com/icon/emilys/128"),
        companyTitle: "Sales Manager"
    )
}
