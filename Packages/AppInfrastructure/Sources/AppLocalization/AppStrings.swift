import Foundation

/// Small localization facade for app and package code.
///
/// Rationale:
/// Call sites provide a default string key while the app target supplies real localization resources through `Localizable.xcstrings`.
public enum AppStrings {
    public static func text(_ keyAndDefaultValue: String) -> String {
        String(localized: String.LocalizationValue(keyAndDefaultValue))
    }

    public static func formatted(_ format: String, _ arguments: CVarArg...) -> String {
        String(format: text(format), arguments: arguments)
    }
}
