import Foundation

/// Throwing JSON encoder helper for network request bodies.
///
/// Important:
/// Encoding failures must propagate to the networking boundary; do not suppress thrown encoder failures.
enum JSONRequestBodyEncoder {
    static func encode<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(value)
    }
}
