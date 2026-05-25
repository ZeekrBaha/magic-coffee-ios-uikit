import UIKit

/// Manages the three-screen checkout flow:
/// PrePaymentListVC → PaymentVC → ConfirmationVC
final class CheckoutCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var parent: (any Coordinator)?

    private let state: AssemblageState
    private var placedOrder: CDOrder?

    init(navigationController: UINavigationController, state: AssemblageState) {
        self.navigationController = navigationController
        self.state = state
    }

    func start() {
        pushPrePaymentList()
    }

    // MARK: - Step 1: PrePaymentList

    private func pushPrePaymentList() {
        let vm = PrePaymentListViewModel(state: state)
        let vc = PrePaymentListViewController(viewModel: vm)
        vc.onNext = { [weak self] in
            self?.pushPayment()
        }
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Step 2: Payment

    private func pushPayment() {
        let vm = PaymentViewModel(state: state, orderService: OrderService.shared)
        let vc = PaymentViewController(viewModel: vm)
        vc.onOrderPlaced = { [weak self] order in
            self?.placedOrder = order
            self?.pushConfirmation(order: order)
        }
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Step 3: Confirmation

    private func pushConfirmation(order: CDOrder) {
        let vm = ConfirmationViewModel(order: order, state: state)
        let vc = ConfirmationViewController(viewModel: vm)
        vc.onBackToHome = { [weak self] in
            self?.popToHome()
        }
        vc.onShowReview = { [weak self] in
            self?.showReviewModal()
        }
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Navigation

    /// Pops all the way back to the catalog (root) and removes this coordinator.
    private func popToHome() {
        navigationController.popToRootViewController(animated: true)
        finish()
    }

    /// Presents the post-order review modal (screen 26) over the confirmation screen.
    func showReviewModal() {
        let viewModel = ReviewViewModel()
        let reviewVC = ReviewViewController(viewModel: viewModel)
        reviewVC.onFinish = { [weak reviewVC] in
            reviewVC?.dismiss(animated: true)
        }
        navigationController.present(reviewVC, animated: true)
    }
}
