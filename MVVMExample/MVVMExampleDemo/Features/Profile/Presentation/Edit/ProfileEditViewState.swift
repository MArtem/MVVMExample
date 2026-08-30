import Foundation

/// Render-ready presentation state consumed by SwiftUI views.
///
/// Formatting policy: expensive localization, date, number, and accessibility strings should be prepared before row/body rendering hot paths.
struct ProfileEditViewState: Equatable {
    var isSaving: Bool = false
    var errorMessage: String?

    var saveButtonTitle: String {
        isSaving ? AppStrings.text("Saving...") : AppStrings.text("Save")
    }
}
