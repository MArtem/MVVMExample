import Foundation

enum ProfileMappingError: Error {
    case missingID
}

struct ProfileDTOMapper {
    func map(_ dto: UserProfileDTO) throws -> UserProfile {
        guard let id = dto.id else {
            throw ProfileMappingError.missingID
        }

        return UserProfile(
            id: id,
            username: dto.username ?? "unknown",
            email: dto.email ?? "",
            firstName: dto.firstName ?? "",
            lastName: dto.lastName ?? "",
            phone: dto.phone,
            imageURL: dto.image.flatMap(URL.init(string:)),
            companyTitle: dto.company?.title
        )
    }
}
