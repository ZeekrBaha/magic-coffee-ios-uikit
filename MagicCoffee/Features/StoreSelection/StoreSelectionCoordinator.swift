import UIKit

protocol StoreSelectionCoordinatorDelegate: AnyObject {
    func storeSelectionCoordinatorDidFinish(_ coordinator: StoreSelectionCoordinator)
}

final class StoreSelectionCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var parent: (any Coordinator)?
    weak var delegate: StoreSelectionCoordinatorDelegate?

    private let storeService: StoreService

    init(navigationController: UINavigationController, storeService: StoreService = .shared) {
        self.navigationController = navigationController
        self.storeService = storeService
    }

    func start() {
        let viewModel = StoreListViewModel(storeService: storeService)
        viewModel.coordinator = self
        let vc = StoreListViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
    }

    /// Called when the user taps a store row — push MapVC with the pre-selected store.
    func showMap(stores: [CDStore], selectedStore: CDStore) {
        let viewModel = MapViewModel(stores: stores, initialSelection: selectedStore)
        viewModel.coordinator = self
        let vc = MapViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    /// Called when the user confirms their selection on MapVC.
    func confirmStoreSelection(storeID: UUID) {
        UserDefaults.standard.set(storeID.uuidString, forKey: "selectedStoreId")
        UserDefaults.standard.set(true, forKey: "mc_store_selected")
        finish()
        delegate?.storeSelectionCoordinatorDidFinish(self)
    }
}
