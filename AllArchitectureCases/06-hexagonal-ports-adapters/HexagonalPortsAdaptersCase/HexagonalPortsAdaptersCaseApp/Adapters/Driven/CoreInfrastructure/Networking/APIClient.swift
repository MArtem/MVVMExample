import Foundation

/// App-layer alias for the neutral infrastructure network boundary.
///
/// Rationale:
/// Feature repositories depend on the local app-facing `APIClient` name while implementation lives in app-local networking support.
typealias APIClient = NetworkClient
