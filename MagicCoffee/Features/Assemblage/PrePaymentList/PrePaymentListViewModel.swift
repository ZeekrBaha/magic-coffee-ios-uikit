import Foundation

final class PrePaymentListViewModel {
    let state: AssemblageState

    struct ItemRow {
        let name: String
        let milk: String?
        let syrup: String?
        let additives: [String]
        let quantity: Int
        let price: Double
    }

    var itemRows: [ItemRow] {
        guard let product = state.selectedProduct,
              let name = product.name,
              let priceDecimal = product.price else { return [] }
        let price = priceDecimal.doubleValue
        let milk = state.milkType == "None" ? nil : state.milkType
        let syrup = state.syrupType == "None" ? nil : state.syrupType
        let additives = state.selectedAdditives
        return [ItemRow(name: name, milk: milk, syrup: syrup, additives: additives, quantity: 1, price: price)]
    }

    var totalText: String {
        let total = itemRows.reduce(0.0) { $0 + $1.price * Double($1.quantity) }
        return String(format: "Total: £%.2f", total)
    }

    init(state: AssemblageState) {
        self.state = state
    }
}
