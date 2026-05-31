import Foundation

public enum JSONRequestBodyEncoder {
    public static func encode<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(value)
    }
}
