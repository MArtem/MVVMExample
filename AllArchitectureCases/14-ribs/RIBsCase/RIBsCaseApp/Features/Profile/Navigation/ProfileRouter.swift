import SwiftUI
import Observation

/// Navigation owner for the profile feature stack.
///
/// Ownership:
/// Owned by `MainCoordinator` for the authenticated app session.
@MainActor
@Observable
final class ProfileRouter {
    var path = NavigationPath()

    func openEdit(_ payload: ProfileEditRoutePayload) {
        path.append(ProfileRoute.edit(payload))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func reset() {
        path = NavigationPath()
    }
}

/// Navigation contract for a feature route boundary.
///
/// Keep payloads limited to route identity and deliberate presentation snapshots; data loading and persistence stay outside navigation.
enum ProfileRoute: Hashable {
    case edit(ProfileEditRoutePayload)
}

/// Navigation contract for a feature route boundary.
///
/// Keep payloads limited to route identity and deliberate presentation snapshots; data loading and persistence stay outside navigation.
struct ProfileEditRoutePayload: Hashable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
}
