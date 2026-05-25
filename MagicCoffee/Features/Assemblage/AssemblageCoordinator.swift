import UIKit

/// Coordinates the 8-screen coffee customization flow.
final class AssemblageCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var parent: (any Coordinator)?

    private let state: AssemblageState

    init(navigationController: UINavigationController, state: AssemblageState) {
        self.navigationController = navigationController
        self.state = state
    }

    func start() {
        showMilkSelection()
    }

    // MARK: - Step 1: Milk (bottom sheet)

    private func showMilkSelection() {
        let vm = MilkSelectionViewModel(state: state)
        let vc = MilkSelectionViewController(viewModel: vm)
        vc.onDismiss = { [weak self] in
            self?.showSyrupSelection()
        }
        vc.modalPresentationStyle = .pageSheet
        navigationController.topViewController?.present(vc, animated: true)
    }

    // MARK: - Step 2: Syrup (bottom sheet)

    private func showSyrupSelection() {
        let vm = SyrupSelectionViewModel(state: state)
        let vc = SyrupSelectionViewController(viewModel: vm)
        vc.onDismiss = { [weak self] in
            self?.pushBaristaSelection()
        }
        vc.modalPresentationStyle = .pageSheet
        navigationController.topViewController?.present(vc, animated: true)
    }

    // MARK: - Step 3: Barista (push)

    private func pushBaristaSelection() {
        let vm = BaristaSelectionViewModel(state: state)
        let vc = BaristaSelectionViewController(viewModel: vm)
        vc.onBaristaSelected = { [weak self] in
            self?.pushCountrySelection()
        }
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Step 4: Country (push)

    private func pushCountrySelection() {
        let vm = CountrySelectionViewModel(state: state)
        let vc = CountrySelectionViewController(viewModel: vm)
        vc.onCountrySelected = { [weak self] in
            self?.pushCoffeeSortSelection()
        }
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Step 5: Coffee Sort (push)

    private func pushCoffeeSortSelection() {
        let vm = CoffeeSortSelectionViewModel(state: state)
        let vc = CoffeeSortSelectionViewController(viewModel: vm)
        vc.onSortSelected = { [weak self] in
            self?.pushAdditivesSelection()
        }
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Step 6: Additives (push)

    private func pushAdditivesSelection() {
        let vm = AdditivesSelectionViewModel(state: state)
        let vc = AdditivesSelectionViewController(viewModel: vm)
        vc.onDone = { [weak self] in
            self?.pushEncyclopedia()
        }
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Step 7: Encyclopedia (push)

    private func pushEncyclopedia() {
        let vm = EncyclopediaViewModel(state: state)
        let vc = EncyclopediaViewController(viewModel: vm)
        vc.onSkip = { [weak self] in
            self?.pushSummary()
        }
        vc.onNext = { [weak self] in
            self?.pushSummary()
        }
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Step 8: Summary (push)

    private func pushSummary() {
        let vm = AssemblageSummaryViewModel(state: state)
        let vc = AssemblageSummaryViewController(viewModel: vm)
        vc.onProceed = { [weak self] in
            self?.handleProceedToOrder()
        }
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Checkout

    private func handleProceedToOrder() {
        let coordinator = CheckoutCoordinator(navigationController: navigationController, state: state)
        coordinator.parent = self
        addChild(coordinator)
        coordinator.start()
    }
}
