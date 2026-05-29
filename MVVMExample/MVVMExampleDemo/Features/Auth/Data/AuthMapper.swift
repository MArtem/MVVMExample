import Foundation

struct AuthMapper {
    func map(_ dto: AuthUserDTO) -> AuthSession {
        AuthSession(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            user: AppUser(
                id: dto.id,
                username: dto.username,
                email: dto.email,
                firstName: dto.firstName,
                lastName: dto.lastName,
                imageURL: dto.image.flatMap(URL.init(string:))
            )
        )
    }
}
