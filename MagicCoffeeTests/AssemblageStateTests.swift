import XCTest
@testable import MagicCoffee

final class AssemblageStateTests: XCTestCase {

    private var state: AssemblageState!

    override func setUpWithError() throws {
        state = AssemblageState()
    }

    override func tearDownWithError() throws {
        state = nil
    }

    func testDefaultMilkIsNone() {
        XCTAssertEqual(state.milkType, "None")
    }

    func testDefaultSyrupIsNone() {
        XCTAssertEqual(state.syrupType, "None")
    }

    func testDefaultCountryIsBrazil() {
        XCTAssertEqual(state.selectedCountry, "Brazil")
    }

    func testDefaultSortIsSantos() {
        XCTAssertEqual(state.selectedCoffeeSort, "Santos")
    }

    func testDefaultAdditivesIsEmpty() {
        XCTAssertTrue(state.selectedAdditives.isEmpty)
    }

    func testSettingAdditives() {
        state.selectedAdditives = ["Nutmeg", "Ice Cream"]
        XCTAssertEqual(state.selectedAdditives.count, 2)
        XCTAssertTrue(state.selectedAdditives.contains("Nutmeg"))
        XCTAssertTrue(state.selectedAdditives.contains("Ice Cream"))
    }
}
