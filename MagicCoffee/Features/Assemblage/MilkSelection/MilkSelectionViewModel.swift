import Foundation

final class MilkSelectionViewModel {
    let options: [String] = ["None", "Cow's", "Lactose-free", "Skimmed", "Vegetable"]
    let state: AssemblageState

    init(state: AssemblageState) {
        self.state = state
    }

    func select(_ milk: String) {
        state.milkType = milk
    }
}
