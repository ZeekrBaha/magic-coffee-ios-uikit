import XCTest

/// Walks the app and captures a named screenshot of every screen.
/// Run with: xcodebuild test -only-testing:MagicCoffeeUITests/ScreenshotCaptureTests
/// Screenshots are saved as keepAlways attachments and extracted from the .xcresult.
///
/// Every interaction is guarded (no raw `.tap()` on a possibly-missing element), because
/// an interaction error on a missing element halts the test even with
/// `continueAfterFailure = true`. The ForgotPassword screen is captured in its own test
/// (fresh launch) so its back-navigation quirk can't break the main flow.
final class ScreenshotCaptureTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments.append("-uitest-reset-auth")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helpers

    private func snap(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let att = XCTAttachment(screenshot: shot)
        att.name = name
        att.lifetime = .keepAlways
        add(att)
    }

    @discardableResult
    private func waitTap(_ element: XCUIElement, _ timeout: TimeInterval = 8) -> Bool {
        guard element.waitForExistence(timeout: timeout) else { return false }
        element.tap()
        return true
    }

    private func type(_ field: XCUIElement, _ text: String) {
        if field.waitForExistence(timeout: 6) {
            field.tap()
            field.typeText(text)
        }
    }

    private func tapCell(_ index: Int = 0, timeout: TimeInterval = 8) {
        let cell = app.tables.cells.element(boundBy: index)
        if cell.waitForExistence(timeout: timeout) { cell.tap() }
    }

    private func goBack() {
        let back = app.navigationBars.buttons.firstMatch
        if back.waitForExistence(timeout: 2) { back.tap() } else { app.swipeRight() }
    }

    // MARK: - Forgot Password (isolated, fresh launch)

    func testCaptureAForgotPassword() throws {
        XCTAssertTrue(app.buttons["splash_next_button"].waitForExistence(timeout: 10))
        snap("00_splash")
        app.buttons["splash_next_button"].tap()

        _ = app.textFields["signin_email_field"].waitForExistence(timeout: 8)
        snap("01_signin")

        if waitTap(app.buttons["Forgot Password?"], 5) {
            _ = app.textFields["forgot_email_field"].waitForExistence(timeout: 5)
            snap("03_forgot_password")
        }
    }

    // MARK: - Main flow (all remaining screens)

    func testCaptureMainFlow() throws {
        // Splash → SignIn
        waitTap(app.buttons["splash_next_button"], 10)
        _ = app.textFields["signin_email_field"].waitForExistence(timeout: 8)

        // Sign Up
        waitTap(app.buttons["signin_signup_link"])
        _ = app.textFields["signup_email_field"].waitForExistence(timeout: 6)
        snap("02_signup")
        let unique = "shot\(Int(Date().timeIntervalSince1970))@mc.com"
        type(app.textFields["signup_email_field"], unique)
        type(app.textFields["signup_address_field"], "Bradford")
        type(app.secureTextFields["signup_password_field"], "secret")
        waitTap(app.buttons["signup_next_button"])

        // Verification (OTP = 1234)
        if app.textFields["otp_digit_0"].waitForExistence(timeout: 6) {
            for (i, ch) in "1234".enumerated() {
                let f = app.textFields["otp_digit_\(i)"]
                if f.exists { f.tap(); f.typeText(String(ch)) }
            }
            snap("04_verification")
            waitTap(app.buttons["otp_next_button"])
        }

        // Store List → Map → select
        _ = app.tables.cells.firstMatch.waitForExistence(timeout: 8)
        snap("05_store_list")
        tapCell(0)
        if app.buttons["map_select_button"].waitForExistence(timeout: 6) {
            snap("06_map")
            app.buttons["map_select_button"].tap()
        }

        // Catalog
        _ = app.collectionViews["catalog_collection_view"].waitForExistence(timeout: 10)
        snap("07_catalog")
        let firstProduct = app.collectionViews.cells.element(boundBy: 0)
        if firstProduct.waitForExistence(timeout: 6) { firstProduct.tap() }

        // Product Detail
        sleep(1)
        snap("08_product_detail")
        waitTap(app.buttons["Assemblage"])

        // Milk (sheet) → Syrup (sheet)
        sleep(1); snap("09_milk_selection");  tapCell(1)
        sleep(1); snap("10_syrup_selection"); tapCell(1)

        // Barista → Country → Sort
        sleep(1); snap("11_barista_selection"); tapCell(0)
        sleep(1); snap("12_country_selection"); tapCell(0)
        sleep(1); snap("13_coffee_sort");       tapCell(0)

        // Additives → Encyclopedia → Summary
        sleep(1); snap("14_additives");          waitTap(app.buttons["Done"])
        sleep(1); snap("15_encyclopedia");       waitTap(app.buttons["Next"])
        sleep(1); snap("16_assemblage_summary"); waitTap(app.buttons["Proceed to Order"])

        // Pre-Payment → Payment → Confirmation
        _ = app.tables["prepayment_items_table"].waitForExistence(timeout: 6)
        snap("17_prepayment")
        waitTap(app.buttons["prepayment_next_button"])

        sleep(1); snap("18_payment"); waitTap(app.buttons["payment_pay_button"])

        _ = app.staticTexts["confirmation_ordered_label"].waitForExistence(timeout: 8)

        // The review modal auto-appears ~1s later. Capture it first, then dismiss it so
        // the confirmation screen can be captured cleanly (without the modal overlay).
        sleep(2)
        if app.staticTexts["review_title"].waitForExistence(timeout: 8)
            || app.buttons["review_nothanks_button"].waitForExistence(timeout: 2) {
            snap("20_review_modal")
            waitTap(app.buttons["review_nothanks_button"], 3)
        }
        sleep(1)
        snap("19_confirmation")
        waitTap(app.buttons["confirmation_back_button"], 4)
        _ = app.collectionViews["catalog_collection_view"].waitForExistence(timeout: 6)

        // My Orders — Ongoing / History
        if waitTap(app.tabBars.buttons["My Orders"], 5) {
            sleep(1); snap("21_orders_ongoing")
            let seg = app.segmentedControls["my_orders_segmented"]
            if seg.waitForExistence(timeout: 3), seg.buttons.count > 1 {
                seg.buttons.element(boundBy: 1).tap()
                sleep(1); snap("22_orders_history")
            }
        }

        // Rewards → Redeem
        if waitTap(app.tabBars.buttons["Rewards"], 5) {
            sleep(1); snap("23_rewards")
            if waitTap(app.buttons["rewards_redeem_button"], 4) {
                sleep(1); snap("24_redeem")
                goBack()
            }
        }

        // Profile
        if waitTap(app.tabBars.buttons["Profile"], 5) {
            sleep(1); snap("25_profile")
        }
    }
}
