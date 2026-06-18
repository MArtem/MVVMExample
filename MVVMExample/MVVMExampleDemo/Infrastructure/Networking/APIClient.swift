import Foundation

/// App-layer alias for the neutral infrastructure network boundary.
///
/// Rationale:
/// Feature repositories depend on the local app name while the implementation stays in the standalone `AppNetworking` package.
typealias APIClient = NetworkClient
