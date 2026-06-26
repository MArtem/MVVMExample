import Foundation

/// Networking primitive used by repository/data adapters.
///
/// Boundary rule: centralize request encoding, response validation, cancellation, and user-safe error mapping outside feature views.
enum JSONBodyEncoder {
    static func encode<T: Encodable>(_ value: T) throws -> Data {
        try JSONRequestBodyEncoder.encode(value)
    }
}
