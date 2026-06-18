import SwiftUI

struct ProfileEditScreen: View {
    @State private var viewModel: ProfileEditViewModel

    init(viewModel: ProfileEditViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        Form {
            Section(AppStrings.text("Personal")) {
                TextField(AppStrings.text("First name"), text: $viewModel.firstName)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.firstNameField)
                TextField(AppStrings.text("Last name"), text: $viewModel.lastName)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.lastNameField)
                TextField(AppStrings.text("Email"), text: $viewModel.email)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.emailField)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }

            if let error = viewModel.state.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(AppTheme.destructive)
                }
            }

            Section {
                Button {
                    viewModel.saveTapped()
                } label: {
                    HStack {
                        if viewModel.state.isSaving {
                            ProgressView()
                        }
                        Text(viewModel.state.saveButtonTitle)
                    }
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.saveButton)
                .disabled(viewModel.state.isSaving)
            }
        }
        .navigationTitle(AppStrings.text("Edit Profile"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppStrings.text("Cancel")) {
                    viewModel.cancelTapped()
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.cancelButton)
            }
        }
    }
}
