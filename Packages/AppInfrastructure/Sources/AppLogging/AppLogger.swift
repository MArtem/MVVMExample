import Foundation

/// Minimal logging boundary for reusable infrastructure.
///
/// Invariant:
/// Callers must pass only redacted or redactable metadata; credentials and tokens must never be logged intentionally.
public protocol AppLogger: Sendable {
    func log(_ message: @autoclosure () -> String)
}

public struct NoOpAppLogger: AppLogger {
    public init() {}
    public func log(_ message: @autoclosure () -> String) {}
}

/// Logger adapter that redacts common credential-like fragments before sending messages to the sink.
public struct RedactingAppLogger: AppLogger {
    private let sink: @Sendable (String) -> Void

    public init(sink: @escaping @Sendable (String) -> Void) {
        self.sink = sink
    }

    public func log(_ message: @autoclosure () -> String) {
        sink(Self.redact(message()))
    }

    public static func redact(_ value: String) -> String {
        var result = value
        let sensitiveKeys = ["authorization", "accessToken", "refreshToken", "password", "token"]
        for key in sensitiveKeys {
            result = result.replacingOccurrences(
                of: "(?i)\(key)[^,&\\s]*",
                with: "\(key)=<redacted>",
                options: .regularExpression
            )
        }
        return result
    }
}
