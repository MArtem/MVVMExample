import SwiftUI

struct ProfileEditScreen: View {
    @State private var interactor: ProfileEditInteractor

    init(interactor: ProfileEditInteractor) {
        _interactor = State(initialValue: interactor)
    }

    var body: some View {
        @Bindable var interactor = interactor

        Form {
            Section(AppStrings.text("Personal")) {
                TextField(AppStrings.text("First name"), text: $interactor.firstName)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.firstNameField)
                TextField(AppStrings.text("Last name"), text: $interactor.lastName)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.lastNameField)
                TextField(AppStrings.text("Email"), text: $interactor.email)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.emailField)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }

            if let error = interactor.state.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(AppTheme.destructive)
                }
            }

            Section {
                Button {
                    interactor.saveTapped()
                } label: {
                    HStack {
                        if interactor.state.isSaving {
                            ProgressView()
                        }
                        Text(interactor.state.saveButtonTitle)
                    }
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.saveButton)
                .disabled(interactor.state.isSaving)
            }
        }
        .navigationTitle(AppStrings.text("Edit Profile"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppStrings.text("Cancel")) {
                    interactor.cancelTapped()
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.cancelButton)
            }
        }
    }
}
