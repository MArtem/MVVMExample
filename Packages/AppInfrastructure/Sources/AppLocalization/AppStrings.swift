import Foundation

public enum AppStrings {
    public static func text(_ keyAndDefaultValue: String) -> String {
        String(localized: String.LocalizationValue(keyAndDefaultValue))
    }

    public static func formatted(_ format: String, _ arguments: CVarArg...) -> String {
        String(format: text(format), arguments: arguments)
    }
}
