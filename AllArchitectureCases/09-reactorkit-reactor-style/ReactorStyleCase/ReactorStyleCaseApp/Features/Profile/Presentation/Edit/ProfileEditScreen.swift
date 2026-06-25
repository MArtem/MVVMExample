import SwiftUI

struct ProfileEditScreen: View {
    @State private var store: ProfileEditReactor

    init(store: ProfileEditReactor) {
        _store = State(initialValue: store)
    }

    var body: some View {
        @Bindable var store = store

        Form {
            Section(AppStrings.text("Personal")) {
                TextField(AppStrings.text("First name"), text: $store.firstName)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.firstNameField)
                TextField(AppStrings.text("Last name"), text: $store.lastName)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.lastNameField)
                TextField(AppStrings.text("Email"), text: $store.email)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.emailField)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }

            if let error = store.state.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(AppTheme.destructive)
                }
            }

            Section {
                Button {
                    store.saveTapped()
                } label: {
                    HStack {
                        if store.state.isSaving {
                            ProgressView()
                        }
                        Text(store.state.saveButtonTitle)
                    }
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.saveButton)
                .disabled(store.state.isSaving)
            }
        }
        .navigationTitle(AppStrings.text("Edit Profile"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppStrings.text("Cancel")) {
                    store.cancelTapped()
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.cancelButton)
            }
        }
    }
}
