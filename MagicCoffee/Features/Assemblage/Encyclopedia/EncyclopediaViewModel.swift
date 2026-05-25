import Foundation

final class EncyclopediaViewModel {
    let state: AssemblageState

    let infoText = """
    Coffee is a brewed drink prepared from roasted coffee beans, the seeds of berries from \
    certain Coffea species. When coffee berries turn from green to bright red in color, they \
    are ready for harvesting. Coffee is darkly colored, bitter, slightly acidic and has a \
    stimulating effect in humans, primarily due to its caffeine content. It is one of the most \
    popular drinks in the world and can be prepared and presented in a variety of ways.
    """

    var priceText: String {
        if let price = state.selectedProduct?.price?.decimalValue {
            let value = NSDecimalNumber(decimal: price).doubleValue
            return String(format: "£%.2f", value)
        }
        return "£0.00"
    }

    init(state: AssemblageState) {
        self.state = state
    }
}
