import Foundation

/// Authentication boundary used by the login flow.
///
/// Responsibilities:
/// - authenticate credentials against the configured backend or approved demo source;
/// - return a domain session only, not transport transport models.
protocol AuthRepository {
    func login(username: String, password: String) async throws -> AuthSession
}
