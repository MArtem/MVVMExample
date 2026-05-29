import SwiftUI

struct ProfileEditScreen: View {
    @State private var viewModel: ProfileEditViewModel

    init(viewModel: ProfileEditViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        Form {
            Section("Personal") {
                TextField("First name", text: $viewModel.firstName)
                TextField("Last name", text: $viewModel.lastName)
                TextField("Email", text: $viewModel.email)
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
                    viewModel.send(.saveTapped)
                } label: {
                    HStack {
                        if viewModel.state.isSaving {
                            ProgressView()
                        }
                        Text(viewModel.state.saveButtonTitle)
                    }
                }
                .disabled(viewModel.state.isSaving)
            }
        }
        .navigationTitle("Edit Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") {
                    viewModel.send(.cancelTapped)
                }
            }
        }
    }
}
