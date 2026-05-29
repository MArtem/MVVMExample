import Foundation

struct ProfileViewStateBuilder {
    func makeContent(from profile: UserProfile) -> ProfileContentViewState {
        ProfileContentViewState(
            id: profile.id,
            displayName: profile.displayName,
            usernameText: "@\(profile.username)",
            emailText: profile.email,
            phoneText: profile.phone ?? "No phone",
            companyText: profile.companyTitle ?? "No company title",
            imageURL: profile.imageURL
        )
    }

    func makeError(from error: Error) -> MessageViewState {
        MessageViewState(
            title: "Couldn’t load profile",
            message: error.localizedDescription,
            retryTitle: "Retry"
        )
    }
}
