import Foundation

struct AppDependencies {
    let apiClient: APIClient
    let authRepository: AuthRepository
    let newsRepository: NewsRepository
    let profileRepository: ProfileRepository

    static func live() -> AppDependencies {
        let apiClient = URLSessionAPIClient(
            baseURL: URL(string: "https://dummyjson.com")!
        )

        return AppDependencies(
            apiClient: apiClient,
            authRepository: LiveAuthRepository(apiClient: apiClient),
            newsRepository: LiveNewsRepository(apiClient: apiClient),
            profileRepository: LiveProfileRepository(apiClient: apiClient)
        )
    }
}
