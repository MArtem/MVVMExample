import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct LoginScreen: View {
    @State private var viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: AppSpacing.lg) {
            Spacer()

            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.actionPrimary)

                Text(viewModel.state.title)
                    .font(AppTypography.largeTitle)
                    .multilineTextAlignment(.center)

                Text(viewModel.state.subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            VStack(spacing: AppSpacing.md) {
                TextField(AppStrings.text("Username"), text: $viewModel.username)
                    .accessibilityIdentifier(AppAccessibilityID.Login.usernameField)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(AppTheme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.field))

                SecureField(AppStrings.text("Password"), text: $viewModel.password)
                    .accessibilityIdentifier(AppAccessibilityID.Login.passwordField)
                    .padding()
                    .background(AppTheme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.field))

                if let error = viewModel.state.errorMessage {
                    Text(error)
                        .accessibilityIdentifier(AppAccessibilityID.Login.errorMessage)
                        .font(AppTypography.bodySmall)
                        .foregroundStyle(AppTheme.destructive)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    viewModel.loginTapped()
                } label: {
                    HStack {
                        if viewModel.state.isLoading {
                            ProgressView()
                        }
                        Text(viewModel.state.loginButtonTitle)
                            .font(AppTypography.button)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(AppAccessibilityID.Login.signInButton)
                .disabled(viewModel.state.isLoading)

                if viewModel.state.showsDemoCredentialsButton {
                    Button(AppStrings.text("Fill demo credentials")) {
                        viewModel.useDemoCredentialsTapped()
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
        viewModel: LoginViewModel(
            repository: MockAuthRepository(),
            demoCredentials: .dummyJSON,
            onLoginSuccess: { _ in }
        )
    )
}
