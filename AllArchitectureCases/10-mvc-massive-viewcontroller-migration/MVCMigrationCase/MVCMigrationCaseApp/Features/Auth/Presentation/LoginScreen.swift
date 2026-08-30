import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct LoginScreen: View {
    @State private var controller: LoginController

    init(controller: LoginController) {
        _controller = State(initialValue: controller)
    }

    var body: some View {
        @Bindable var controller = controller

        VStack(spacing: AppSpacing.lg) {
            Spacer()

            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.actionPrimary)

                Text(controller.state.title)
                    .font(AppTypography.largeTitle)
                    .multilineTextAlignment(.center)

                Text(controller.state.subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            VStack(spacing: AppSpacing.md) {
                TextField(AppStrings.text("Username"), text: $controller.username)
                    .accessibilityIdentifier(AppAccessibilityID.Login.usernameField)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(AppTheme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.field))

                SecureField(AppStrings.text("Password"), text: $controller.password)
                    .accessibilityIdentifier(AppAccessibilityID.Login.passwordField)
                    .padding()
                    .background(AppTheme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.field))

                if let error = controller.state.errorMessage {
                    Text(error)
                        .accessibilityIdentifier(AppAccessibilityID.Login.errorMessage)
                        .font(AppTypography.bodySmall)
                        .foregroundStyle(AppTheme.destructive)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    controller.loginTapped()
                } label: {
                    HStack {
                        if controller.state.isLoading {
                            ProgressView()
                        }
                        Text(controller.state.loginButtonTitle)
                            .font(AppTypography.button)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(AppAccessibilityID.Login.signInButton)
                .disabled(controller.state.isLoading)

                if controller.state.showsDemoCredentialsButton {
                    Button(AppStrings.text("Fill demo credentials")) {
                        controller.useDemoCredentialsTapped()
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(AppAccessibilityID.Login.fillDemoCredentialsButton)
                }
            }

            Spacer()
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.backgroundBase)
    }
}

#Preview {
    LoginScreen(
        controller: LoginController(
            repository: MockAuthRepository(),
            demoCredentials: .dummyJSON,
            onLoginSuccess: { _ in }
        )
    )
}
