import Foundation

/// Minimal logging boundary for app-local infrastructure.
///
/// Invariant:
/// Callers must pass only redacted or redactable metadata; credentials and tokens must never be logged intentionally.
protocol AppLogger: Sendable {
    func log(_ message: @autoclosure () -> String)
}

struct NoOpAppLogger: AppLogger {
    init() {}
    func log(_ message: @autoclosure () -> String) {}
}

/// Logger adapter that redacts common credential-like fragments before sending messages to the sink.
struct RedactingAppLogger: AppLogger {
    private let sink: @Sendable (String) -> Void

    init(sink: @escaping @Sendable (String) -> Void) {
        self.sink = sink
    }

    func log(_ message: @autoclosure () -> String) {
        sink(Self.redact(message()))
    }

    static func redact(_ value: String) -> String {
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
