import Foundation

/// Small localization facade for app and package code.
///
/// Rationale:
/// Call sites provide a default string key while the app target supplies real localization resources through `Localizable.xcstrings`.
enum AppStrings {
    static func text(_ keyAndDefaultValue: String) -> String {
        NSLocalizedString(keyAndDefaultValue, comment: "")
    }

    static func formatted(_ format: String, _ arguments: CVarArg...) -> String {
        String(format: text(format), locale: .current, arguments: arguments)
    }

    static func localizedNumber(_ value: Int) -> String {
        NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
    }

    static func localizedNumber(_ value: Double, minimumFractionDigits: Int = 0, maximumFractionDigits: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.1f", locale: .current, value)
    }
}
