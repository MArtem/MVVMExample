import SwiftUI

struct LoginScreen: View {
    @State private var interactor: LoginInteractor

    init(interactor: LoginInteractor) {
        _interactor = State(initialValue: interactor)
    }

    var body: some View {
        @Bindable var interactor = interactor

        VStack(spacing: AppSpacing.lg) {
            Spacer()

            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.actionPrimary)

                Text(interactor.state.title)
                    .font(AppTypography.largeTitle)
                    .multilineTextAlignment(.center)

                Text(interactor.state.subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            VStack(spacing: AppSpacing.md) {
                TextField(AppStrings.text("Username"), text: $interactor.username)
                    .accessibilityIdentifier(AppAccessibilityID.Login.usernameField)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(AppTheme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.field))

                SecureField(AppStrings.text("Password"), text: $interactor.password)
                    .accessibilityIdentifier(AppAccessibilityID.Login.passwordField)
                    .padding()
                    .background(AppTheme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.field))

                if let error = interactor.state.errorMessage {
                    Text(error)
                        .accessibilityIdentifier(AppAccessibilityID.Login.errorMessage)
                        .font(AppTypography.bodySmall)
                        .foregroundStyle(AppTheme.destructive)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    interactor.loginTapped()
                } label: {
                    HStack {
                        if interactor.state.isLoading {
                            ProgressView()
                        }
                        Text(interactor.state.loginButtonTitle)
                            .font(AppTypography.button)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(AppAccessibilityID.Login.signInButton)
                .disabled(interactor.state.isLoading)

                if interactor.state.showsDemoCredentialsButton {
                    Button(AppStrings.text("Fill demo credentials")) {
                        interactor.useDemoCredentialsTapped()
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
        interactor: LoginInteractor(
            repository: MockAuthRepository(),
            demoCredentials: .dummyJSON,
            onLoginSuccess: { _ in }
        )
    )
}
