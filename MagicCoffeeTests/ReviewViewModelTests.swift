import XCTest
@testable import MagicCoffee

final class ReviewViewModelTests: XCTestCase {

    private func makeViewModel() -> ReviewViewModel {
        ReviewViewModel()
    }

    // MARK: - Initial state

    func testInitialRatingIsZero() {
        let vm = makeViewModel()
        XCTAssertEqual(vm.rating, 0)
    }

    func testCanSubmitFalseWhenNoRating() {
        let vm = makeViewModel()
        XCTAssertFalse(vm.canSubmit)
    }

    // MARK: - Selecting a rating

    func testSelectRatingUpdatesRating() {
        let vm = makeViewModel()
        vm.selectRating(4)
        XCTAssertEqual(vm.rating, 4)
    }

    func testCanSubmitTrueWhenRated() {
        let vm = makeViewModel()
        vm.selectRating(1)
        XCTAssertTrue(vm.canSubmit)
    }

    // MARK: - Out-of-range guards

    func testSelectRatingIgnoresZeroAndBelow() {
        let vm = makeViewModel()
        vm.selectRating(3)
        vm.selectRating(0)
        vm.selectRating(-2)
        XCTAssertEqual(vm.rating, 3, "Out-of-range values must not overwrite a valid rating")
    }

    func testSelectRatingIgnoresAboveFive() {
        let vm = makeViewModel()
        vm.selectRating(5)
        vm.selectRating(6)
        XCTAssertEqual(vm.rating, 5, "Values above 5 must be ignored")
    }
}
