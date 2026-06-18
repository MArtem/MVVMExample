import Foundation

enum JSONBodyEncoder {
    static func encode<T: Encodable>(_ value: T) throws -> Data {
        try JSONRequestBodyEncoder.encode(value)
    }
}
