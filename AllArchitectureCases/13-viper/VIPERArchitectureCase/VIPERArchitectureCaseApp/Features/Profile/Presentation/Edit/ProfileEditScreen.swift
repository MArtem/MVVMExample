import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct ProfileEditScreen: View {
    @State private var presenter: ProfileEditPresenter

    init(presenter: ProfileEditPresenter) {
        _presenter = State(initialValue: presenter)
    }

    var body: some View {
        @Bindable var presenter = presenter

        Form {
            Section(AppStrings.text("Personal")) {
                TextField(AppStrings.text("First name"), text: $presenter.firstName)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.firstNameField)
                TextField(AppStrings.text("Last name"), text: $presenter.lastName)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.lastNameField)
                TextField(AppStrings.text("Email"), text: $presenter.email)
                    .accessibilityIdentifier(AppAccessibilityID.Profile.emailField)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }

            if let error = presenter.state.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(AppTheme.destructive)
                }
            }

            Section {
                Button {
                    presenter.saveTapped()
                } label: {
                    HStack {
                        if presenter.state.isSaving {
                            ProgressView()
                        }
                        Text(presenter.state.saveButtonTitle)
                    }
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.saveButton)
                .disabled(presenter.state.isSaving)
            }
        }
        .navigationTitle(AppStrings.text("Edit Profile"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppStrings.text("Cancel")) {
                    presenter.cancelTapped()
                }
                .accessibilityIdentifier(AppAccessibilityID.Profile.cancelButton)
            }
        }
    }
}
