import Foundation
import AppNetworking

/// App-layer alias for the neutral infrastructure network boundary.
///
/// Rationale:
/// Feature repositories depend on the local app name while the implementation stays in `AppInfrastructure`.
typealias APIClient = NetworkClient
