import Foundation

final class CoffeeSortSelectionViewModel {
    let sorts: [String] = [
        "Santos", "Bourbon Santos", "Colombia", "Kenya",
        "Minas", "Rio", "Canilan", "Flat Beat"
    ]
    let state: AssemblageState

    init(state: AssemblageState) {
        self.state = state
    }

    func select(_ sort: String) {
        state.selectedCoffeeSort = sort
    }
}
