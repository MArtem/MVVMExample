import SwiftUI

struct LoginScreen: View {
    @State private var presenter: LoginPresenter

    init(presenter: LoginPresenter) {
        _presenter = State(initialValue: presenter)
    }

    var body: some View {
        @Bindable var presenter = presenter

        VStack(spacing: AppSpacing.lg) {
            Spacer()

            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.actionPrimary)

                Text(presenter.state.title)
                    .font(AppTypography.largeTitle)
                    .multilineTextAlignment(.center)

                Text(presenter.state.subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            VStack(spacing: AppSpacing.md) {
                TextField(AppStrings.text("Username"), text: $presenter.username)
                    .accessibilityIdentifier(AppAccessibilityID.Login.usernameField)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(AppTheme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.field))

                SecureField(AppStrings.text("Password"), text: $presenter.password)
                    .accessibilityIdentifier(AppAccessibilityID.Login.passwordField)
                    .padding()
                    .background(AppTheme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.field))

                if let error = presenter.state.errorMessage {
                    Text(error)
                        .accessibilityIdentifier(AppAccessibilityID.Login.errorMessage)
                        .font(AppTypography.bodySmall)
                        .foregroundStyle(AppTheme.destructive)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    presenter.loginTapped()
                } label: {
                    HStack {
                        if presenter.state.isLoading {
                            ProgressView()
                        }
                        Text(presenter.state.loginButtonTitle)
                            .font(AppTypography.button)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(AppAccessibilityID.Login.signInButton)
                .disabled(presenter.state.isLoading)

                if presenter.state.showsDemoCredentialsButton {
                    Button(AppStrings.text("Fill demo credentials")) {
                        presenter.useDemoCredentialsTapped()
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
        presenter: LoginPresenter(
            repository: MockAuthRepository(),
            demoCredentials: .dummyJSON,
            onLoginSuccess: { _ in }
        )
    )
}
