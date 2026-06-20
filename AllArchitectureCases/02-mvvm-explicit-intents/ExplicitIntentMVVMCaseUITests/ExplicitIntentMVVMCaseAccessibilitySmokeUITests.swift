import XCTest

final class ExplicitIntentMVVMCaseAccessibilitySmokeUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["EXPLICIT_INTENT_MVVM_CASE_UI_TEST_MODE"] = "1"
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testLoginScreenExposesAccessibleControls() throws {
        XCTAssertTrue(app.textFields[AccessibilityID.Login.usernameField].waitForExistence(timeout: 3))
        XCTAssertTrue(app.secureTextFields[AccessibilityID.Login.passwordField].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.Login.signInButton].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.Login.fillDemoCredentialsButton].exists)
    }

    func testNewsAndProfilePrimaryControlsRemainAccessibleAfterDemoLogin() throws {
        signInWithDemoCredentials()

        XCTAssertTrue(app.scrollViews[AccessibilityID.News.list].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons[AccessibilityID.News.cardOpenButton(id: 101)].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons[AccessibilityID.News.cardLikeButton(id: 101)].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.News.cardCommentsButton(id: 101)].exists)

        app.buttons[AccessibilityID.News.cardOpenButton(id: 101)].tap()
        XCTAssertTrue(app.buttons[AccessibilityID.News.detailFavoriteButton].waitForExistence(timeout: 3))

        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.buttons[AccessibilityID.Profile.editButton].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons[AccessibilityID.Profile.logoutButton].exists)

        app.buttons[AccessibilityID.Profile.editButton].tap()
        XCTAssertTrue(app.textFields[AccessibilityID.Profile.firstNameField].waitForExistence(timeout: 3))
        XCTAssertTrue(app.textFields[AccessibilityID.Profile.lastNameField].exists)
        XCTAssertTrue(app.textFields[AccessibilityID.Profile.emailField].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.Profile.saveButton].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.Profile.cancelButton].exists)

        app.buttons[AccessibilityID.Profile.cancelButton].tap()
        XCTAssertTrue(app.buttons[AccessibilityID.Profile.logoutButton].waitForExistence(timeout: 3))
        app.buttons[AccessibilityID.Profile.logoutButton].tap()
        XCTAssertTrue(app.buttons[AccessibilityID.Login.signInButton].waitForExistence(timeout: 3))
    }

    private func signInWithDemoCredentials() {
        XCTAssertTrue(app.buttons[AccessibilityID.Login.fillDemoCredentialsButton].waitForExistence(timeout: 3))
        app.buttons[AccessibilityID.Login.fillDemoCredentialsButton].tap()
        app.buttons[AccessibilityID.Login.signInButton].tap()
    }
}

private enum AccessibilityID {
    enum Login {
        static let usernameField = "login.usernameField"
        static let passwordField = "login.passwordField"
        static let signInButton = "login.signInButton"
        static let fillDemoCredentialsButton = "login.fillDemoCredentialsButton"
    }

    enum News {
        static let list = "news.list"
        static let detailFavoriteButton = "news.detail.favoriteButton"

        static func cardOpenButton(id: Int) -> String {
            "news.card.\(id).openButton"
        }

        static func cardLikeButton(id: Int) -> String {
            "news.card.\(id).likeButton"
        }

        static func cardCommentsButton(id: Int) -> String {
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
