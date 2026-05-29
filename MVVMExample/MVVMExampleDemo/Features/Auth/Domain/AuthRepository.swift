import Foundation

protocol AuthRepository {
    func login(username: String, password: String) async throws -> AuthSession
}
