import Foundation

struct ProfileEditViewState: Equatable {
    var isSaving: Bool = false
    var errorMessage: String?

    var saveButtonTitle: String {
        isSaving ? "Saving..." : "Save"
    }
}
