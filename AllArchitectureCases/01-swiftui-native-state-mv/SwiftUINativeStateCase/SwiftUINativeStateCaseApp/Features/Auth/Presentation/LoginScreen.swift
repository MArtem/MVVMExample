import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct LoginScreen: View {
    @State private var model: LoginModel

    init(model: LoginModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        @Bindable var model = model

        VStack(spacing: AppSpacing.lg) {
            Spacer()

            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.actionPrimary)

                Text(model.state.title)
                    .font(AppTypography.largeTitle)
                    .multilineTextAlignment(.center)

                Text(model.state.subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            VStack(spacing: AppSpacing.md) {
                TextField(AppStrings.text("Username"), text: $model.username)
                    .accessibilityIdentifier(AppAccessibilityID.Login.usernameField)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(AppTheme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.field))

                SecureField(AppStrings.text("Password"), text: $model.password)
                    .accessibilityIdentifier(AppAccessibilityID.Login.passwordField)
                    .padding()
                    .background(AppTheme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.field))

                if let error = model.state.errorMessage {
                    Text(error)
                        .accessibilityIdentifier(AppAccessibilityID.Login.errorMessage)
                        .font(AppTypography.bodySmall)
                        .foregroundStyle(AppTheme.destructive)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    model.loginTapped()
                } label: {
                    HStack {
                        if model.state.isLoading {
                            ProgressView()
                        }
                        Text(model.state.loginButtonTitle)
                            .font(AppTypography.button)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(AppAccessibilityID.Login.signInButton)
                .disabled(model.state.isLoading)

                if model.state.showsDemoCredentialsButton {
                    Button(AppStrings.text("Fill demo credentials")) {
                        model.useDemoCredentialsTapped()
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
        model: LoginModel(
            repository: MockAuthRepository(),
            demoCredentials: .dummyJSON,
            onLoginSuccess: { _ in }
        )
    )
}
