import Foundation

final class AdditivesSelectionViewModel {
    let additives: [String] = [
        "Ceylon Cinnamon", "Grated Chocolate", "Liquid Chocolate",
        "Marshmallow", "Whipped Cream", "Cream", "Nutmeg", "Ice Cream"
    ]
    let state: AssemblageState

    init(state: AssemblageState) {
        self.state = state
    }

    func isSelected(_ additive: String) -> Bool {
        state.selectedAdditives.contains(additive)
    }

    func toggle(_ additive: String) {
        if isSelected(additive) {
            state.selectedAdditives.removeAll { $0 == additive }
        } else {
            state.selectedAdditives.append(additive)
        }
    }
}
