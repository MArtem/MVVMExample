import Foundation

enum AppAccessibilityID {
    enum Login {
        static let usernameField = "login.usernameField"
        static let passwordField = "login.passwordField"
        static let signInButton = "login.signInButton"
        static let fillDemoCredentialsButton = "login.fillDemoCredentialsButton"
        static let errorMessage = "login.errorMessage"
    }

    enum News {
        static let list = "news.list"
        static let detailFavoriteButton = "news.detail.favoriteButton"

        static func cardOpenButton(id: NewsArticle.ID) -> String {
            "news.card.\(id).openButton"
        }

        static func cardLikeButton(id: NewsArticle.ID) -> String {
            "news.card.\(id).likeButton"
        }

        static func cardCommentsButton(id: NewsArticle.ID) -> String {
            "news.card.\(id).commentsButton"
        }
    }

    enum Profile {
        static let editButton = "profile.editButton"
        static let logoutButton = "profile.logoutButton"
        static let firstNameField = "profile.edit.firstNameField"
        static let lastNameField = "profile.edit.lastNameField"
        static let emailField = "profile.edit.emailField"
        static let saveButton = "profile.edit.saveButton"
        static let cancelButton = "profile.edit.cancelButton"
    }
}
