import Foundation

/// Data-boundary mapping contract that converts transport shapes into app/domain models.
///
/// Failure behavior: throw explicit mapping errors for invalid backend payloads instead of manufacturing silent placeholder domain data.
enum ProfileMappingError: Error {
    case missingID
}

/// Converts profile transport DTOs into domain models.
///
/// Boundary rule:
/// DTO optionality and backend field shape must be handled here before data reaches Reactors.
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
