import XCTest

final class AuthFlowUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-uitest-reset-auth")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func waitFor(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        element.waitForExistence(timeout: timeout)
    }

    func testSplashScreenAppears() throws {
        let nextButton = app.buttons["splash_next_button"]
        XCTAssertTrue(waitFor(nextButton), "Splash next button should be visible")
        XCTAssertTrue(app.staticTexts["Magic coffee on order..."].exists)
    }

    func testNavigateToSignIn() throws {
        let splashNext = app.buttons["splash_next_button"]
        XCTAssertTrue(waitFor(splashNext))
        splashNext.tap()

        XCTAssertTrue(waitFor(app.textFields["signin_email_field"]),
                      "Sign in email field should appear")
    }

    func testNavigateToSignUp() throws {
        app.buttons["splash_next_button"].tap()
        XCTAssertTrue(waitFor(app.textFields["signin_email_field"]))

        app.buttons["signin_signup_link"].tap()
        XCTAssertTrue(waitFor(app.textFields["signup_email_field"]),
                      "Sign up email field should appear")
    }

    func testSignUpAndVerify() throws {
        app.buttons["splash_next_button"].tap()
        XCTAssertTrue(waitFor(app.textFields["signin_email_field"]))
        app.buttons["signin_signup_link"].tap()

        let email = app.textFields["signup_email_field"]
        XCTAssertTrue(waitFor(email))
        let unique = "user\(Int(Date().timeIntervalSince1970))@b.com"
        email.tap()
        email.typeText(unique)

        let address = app.textFields["signup_address_field"]
        address.tap()
        address.typeText("Bradford")

        let password = app.secureTextFields["signup_password_field"]
        password.tap()
        password.typeText("secret")

        app.buttons["signup_next_button"].tap()

        // Verification screen
        let firstDigit = app.textFields["otp_digit_0"]
        XCTAssertTrue(waitFor(firstDigit), "OTP screen should appear")
        enterOTP("1234")
        app.buttons["otp_next_button"].tap()

        // On success, auth finishes and the splash/signin elements should be gone.
        let errorLabel = app.staticTexts["auth_error_label"]
        XCTAssertFalse(errorLabel.exists, "No error should show for valid OTP")
        XCTAssertFalse(app.textFields["otp_digit_0"].waitForExistence(timeout: 2),
                       "OTP screen should be dismissed after valid code")
    }

    func testInvalidOTPShowsError() throws {
        app.buttons["splash_next_button"].tap()
        XCTAssertTrue(waitFor(app.textFields["signin_email_field"]))
        app.buttons["signin_signup_link"].tap()

        let email = app.textFields["signup_email_field"]
        XCTAssertTrue(waitFor(email))
        let unique = "bad\(Int(Date().timeIntervalSince1970))@b.com"
        email.tap()
        email.typeText(unique)

        let password = app.secureTextFields["signup_password_field"]
        password.tap()
        password.typeText("secret")

        app.buttons["signup_next_button"].tap()

        let firstDigit = app.textFields["otp_digit_0"]
        XCTAssertTrue(waitFor(firstDigit))
        enterOTP("9999")
        app.buttons["otp_next_button"].tap()

        XCTAssertTrue(waitFor(app.staticTexts["auth_error_label"]),
                      "Error should appear for invalid OTP")
    }

    private func enterOTP(_ code: String) {
        for (index, char) in code.enumerated() {
            let field = app.textFields["otp_digit_\(index)"]
            if !field.exists { continue }
            field.tap()
            field.typeText(String(char))
        }
    }
}
