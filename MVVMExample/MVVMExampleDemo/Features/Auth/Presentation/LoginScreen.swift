import SwiftUI

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
                TextField("Username", text: $viewModel.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(AppTheme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.field))

                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(AppTheme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.field))

                if let error = viewModel.state.errorMessage {
                    Text(error)
                        .font(AppTypography.bodySmall)
                        .foregroundStyle(AppTheme.destructive)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    viewModel.send(.loginTapped)
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
                .disabled(viewModel.state.isLoading)

                Button("Fill demo credentials") {
                    viewModel.send(.useDemoCredentialsTapped)
                }
                .buttonStyle(.plain)
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
            onLoginSuccess: { _ in }
        )
    )
}
