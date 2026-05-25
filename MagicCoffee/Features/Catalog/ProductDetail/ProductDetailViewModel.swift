import Combine
import Foundation

enum CoffeeSize: String, CaseIterable {
    case ristretto = "Ristretto"
    case oneShot   = "One shot"
    case twoShots  = "Two shots"
}

enum ServiceType: String, CaseIterable {
    case onsite   = "Onsite"
    case takeaway = "Takeaway"
}

enum TimeChoice: String, CaseIterable {
    case immediate = "Now"
    case scheduled = "Later"
}

final class ProductDetailViewModel: BaseViewModel {
    // MARK: - Inputs (published so view can bind)
    @Published var selectedSize: CoffeeSize = .oneShot
    @Published var selectedServiceType: ServiceType = .onsite
    @Published var selectedTimeChoice: TimeChoice = .immediate

    // MARK: - Output
    @Published private(set) var totalPrice: Decimal

    let product: CDProduct

    init(product: CDProduct) {
        self.product = product
        self.totalPrice = product.price?.decimalValue ?? 0
        super.init()
        bindTotalPrice()
    }

    // MARK: - Actions

    /// Called by the "Assemblage" button — starts the assemblage flow via CatalogCoordinator.
    func startAssemblage() {
        (coordinator as? CatalogCoordinator)?.startAssemblage(product: product)
    }

    /// Called by the "Next →" button — same hook as assemblage for now.
    func proceedToNext() {
        (coordinator as? CatalogCoordinator)?.startAssemblage(product: product)
    }

    // MARK: - Private

    private func bindTotalPrice() {
        // Price stays constant for now (no size surcharge defined).
        // Combine the size selection into price computation when pricing rules are known.
        $selectedSize
            .map { [weak self] _ -> Decimal in
                self?.product.price?.decimalValue ?? 0
            }
            .assign(to: &$totalPrice)
    }
}
