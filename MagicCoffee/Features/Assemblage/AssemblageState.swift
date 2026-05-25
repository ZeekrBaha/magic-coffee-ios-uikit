import Foundation

/// Shared mutable state passed through the assemblage flow.
final class AssemblageState {
    var selectedProduct: CDProduct?
    var milkType: String = "None"
    var syrupType: String = "None"
    var selectedBaristaID: UUID?
    var selectedCountry: String = "Brazil"
    var selectedCoffeeSort: String = "Santos"
    var selectedAdditives: [String] = []
    var isOnsite: Bool = true
    var size: String = "One shot"

    // Set by CheckoutCoordinator / StoreSelectionCoordinator before checkout.
    var selectedStoreID: UUID?
    var selectedStoreName: String?
}
