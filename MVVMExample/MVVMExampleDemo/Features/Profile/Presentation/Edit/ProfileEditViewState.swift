import Foundation
import AppLocalization

struct ProfileEditViewState: Equatable {
    var isSaving: Bool = false
    var errorMessage: String?

    var saveButtonTitle: String {
        isSaving ? AppStrings.text("Saving...") : AppStrings.text("Save")
    }
}
