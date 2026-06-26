import Foundation

/// Render-ready presentation state consumed by SwiftUI views.
///
/// Formatting policy: expensive localization, date, number, and accessibility strings should be prepared before row/body rendering hot paths.
struct LoginViewState: Equatable {
    var isLoading: Bool = false
    var errorMessage: String?
    var showsDemoCredentialsButton: Bool = false

    var title: String { AppStrings.text("MVP Passive View Case") }
    var subtitle: String { AppStrings.text("Use DummyJSON demo login") }
    var loginButtonTitle: String { isLoading ? AppStrings.text("Signing in...") : AppStrings.text("Sign In") }
}
