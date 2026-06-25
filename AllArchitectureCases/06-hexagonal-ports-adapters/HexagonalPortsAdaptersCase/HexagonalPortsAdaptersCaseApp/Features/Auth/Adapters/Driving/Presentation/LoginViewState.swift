import Foundation

struct LoginViewState: Equatable {
    var isLoading: Bool = false
    var errorMessage: String?
    var showsDemoCredentialsButton: Bool = false

    var title: String { AppStrings.text("Hexagonal Ports & Adapters Case") }
    var subtitle: String { AppStrings.text("Use DummyJSON demo login") }
    var loginButtonTitle: String { isLoading ? AppStrings.text("Signing in...") : AppStrings.text("Sign In") }
}
