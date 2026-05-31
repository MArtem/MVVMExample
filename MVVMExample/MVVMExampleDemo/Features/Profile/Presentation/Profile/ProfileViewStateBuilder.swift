import Foundation

struct ProfileViewStateBuilder {
    func makeContent(from profile: UserProfile) -> ProfileContentViewState {
        ProfileContentViewState(
            id: profile.id,
            firstName: profile.firstName,
            lastName: profile.lastName,
            displayName: profile.displayName,
            usernameText: "@\(profile.username)",
            emailText: profile.email,
            phoneText: profile.phone ?? AppStrings.text("No phone"),
            companyText: profile.companyTitle ?? AppStrings.text("No company title"),
            imageURL: profile.imageURL
        )
    }

    func makeError(from error: Error) -> MessageViewState {
        MessageViewState(
            title: AppStrings.text("Couldn’t load profile"),
            message: error.localizedDescription,
            retryTitle: AppStrings.text("Retry")
        )
    }
}
