import SwiftUI

struct ProfileEditScreen: View {
    @State private var controller: ProfileEditController

    init(controller: ProfileEditController) {
        _controller = State(initialValue: controller)
    }

    var body: some View {
        @Bindable var controller = controller

        Form {
            Section(AppStrings.text("Personal")) {
                TextField(AppStrings.text("First name"), text: $controller.firstName)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.firstNameField)
                TextField(AppStrings.text("Last name"), text: $controller.lastName)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.lastNameField)
                TextField(AppStrings.text("Email"), text: $controller.email)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.emailField)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }

            if let error = controller.state.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(AppTheme.destructive)
                }
            }

            Section {
                Button {
                    controller.saveTapped()
                } label: {
                    HStack {
                        if controller.state.isSaving {
                            ProgressView()
                        }
                        Text(controller.state.saveButtonTitle)
                    }
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.saveButton)
                .disabled(controller.state.isSaving)
            }
        }
        .navigationTitle(AppStrings.text("Edit Profile"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppStrings.text("Cancel")) {
                    controller.cancelTapped()
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.cancelButton)
            }
        }
    }
}
