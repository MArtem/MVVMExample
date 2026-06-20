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

enum ProfileRoute: Hashable {
    case edit(ProfileEditRoutePayload)
}

struct ProfileEditRoutePayload: Hashable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
}
