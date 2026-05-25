import XCTest
import UIKit
@testable import MagicCoffee

final class VerificationViewModelTests: XCTestCase {

    private final class SpyAuthDelegate: AuthCoordinatorDelegate {
        var didFinishCalled = false
        func authCoordinatorDidFinish(_ coordinator: AuthCoordinator) {
            didFinishCalled = true
        }
    }

    private func makeCoordinator() -> (AuthCoordinator, SpyAuthDelegate) {
        let coordinator = AuthCoordinator(navigationController: UINavigationController())
        let delegate = SpyAuthDelegate()
        coordinator.delegate = delegate
        return (coordinator, delegate)
    }

    func testValidOTPAdvancesFlow() {
        let (coordinator, delegate) = makeCoordinator()
        let viewModel = VerificationViewModel(email: "a@b.com")
        viewModel.coordinator = coordinator

        viewModel.code = "1234"
        viewModel.verify()

        XCTAssertTrue(delegate.didFinishCalled)
        XCTAssertNil(viewModel.error)
    }

    func testInvalidOTPSetsError() {
        let (coordinator, delegate) = makeCoordinator()
        let viewModel = VerificationViewModel(email: "a@b.com")
        viewModel.coordinator = coordinator

        viewModel.code = "9999"
        viewModel.verify()

        XCTAssertFalse(delegate.didFinishCalled)
        XCTAssertEqual(viewModel.error, AuthError.invalidOTP.localizedDescription)
    }
}
