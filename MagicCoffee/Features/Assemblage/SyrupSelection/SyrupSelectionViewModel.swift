import Foundation

final class SyrupSelectionViewModel {
    let options: [String] = ["None", "Amaretto", "Coconut", "Vanilla", "Caramel"]
    let state: AssemblageState

    init(state: AssemblageState) {
        self.state = state
    }

    func select(_ syrup: String) {
        state.syrupType = syrup
    }
}
