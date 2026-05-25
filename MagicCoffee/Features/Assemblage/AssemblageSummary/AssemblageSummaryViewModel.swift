import Foundation

final class AssemblageSummaryViewModel {
    let state: AssemblageState

    struct SettingsRow {
        let title: String
        let value: String
    }

    var settingsRows: [SettingsRow] {
        [
            SettingsRow(title: "Type", value: state.selectedProduct?.name ?? "—"),
            SettingsRow(title: "Sort", value: state.selectedCoffeeSort),
            SettingsRow(title: "Roasting", value: "★★★"),
            SettingsRow(title: "Grinding", value: "Medium"),
            SettingsRow(title: "Milk", value: state.milkType),
            SettingsRow(title: "Syrup", value: state.syrupType),
        ]
    }

    struct ItemRow {
        let name: String
        let quantity: Int
        let price: Double
    }

    var itemRows: [ItemRow] {
        guard let product = state.selectedProduct,
              let name = product.name,
              let priceDecimal = product.price else { return [] }
        let price = NSDecimalNumber(decimal: priceDecimal.decimalValue).doubleValue
        return [ItemRow(name: name, quantity: 1, price: price)]
    }

    var totalPriceText: String {
        let total = itemRows.reduce(0.0) { $0 + $1.price * Double($1.quantity) }
        return String(format: "£%.2f", total)
    }

    init(state: AssemblageState) {
        self.state = state
    }
}
