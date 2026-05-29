import Foundation

struct LoginViewState: Equatable {
    var isLoading: Bool = false
    var errorMessage: String?

    var title: String { "Best MVVM Demo" }
    var subtitle: String { "Use DummyJSON demo login" }
    var loginButtonTitle: String { isLoading ? "Signing in..." : "Sign In" }
}
