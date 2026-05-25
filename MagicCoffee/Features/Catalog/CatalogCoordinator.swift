import UIKit

final class CatalogCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var parent: (any Coordinator)?

    private let productService: ProductService

    init(navigationController: UINavigationController, productService: ProductService = .shared) {
        self.navigationController = navigationController
        self.productService = productService
    }

    func start() {
        let viewModel = CatalogViewModel(productService: productService)
        viewModel.coordinator = self
        let vc = CatalogViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
    }

    /// Push the product detail screen for the selected product.
    func showProductDetail(product: CDProduct) {
        let viewModel = ProductDetailViewModel(product: product)
        viewModel.coordinator = self
        let vc = ProductDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    /// Starts the assemblage flow for the selected product.
    func startAssemblage(product: CDProduct) {
        let state = AssemblageState()
        state.selectedProduct = product
        // Carry the store chosen during store-selection into the order-in-progress.
        // Payment requires a store ID to place the order; without this it silently no-ops.
        if let idString = UserDefaults.standard.string(forKey: "selectedStoreId"),
           let storeID = UUID(uuidString: idString) {
            state.selectedStoreID = storeID
        }
        let coordinator = AssemblageCoordinator(navigationController: navigationController, state: state)
        coordinator.parent = self
        addChild(coordinator)
        coordinator.start()
    }
}
