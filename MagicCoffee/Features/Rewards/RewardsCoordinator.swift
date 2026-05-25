import UIKit

final class RewardsCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var parent: (any Coordinator)?

    private let loyaltyService: LoyaltyService
    private let authService: AuthService

    init(
        navigationController: UINavigationController,
        loyaltyService: LoyaltyService = .shared,
        authService: AuthService = .shared
    ) {
        self.navigationController = navigationController
        self.loyaltyService = loyaltyService
        self.authService = authService
    }

    func start() {
        let viewModel = RewardsViewModel(loyaltyService: loyaltyService, authService: authService)
        viewModel.coordinator = self
        let vc = RewardsViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
    }

    /// Pushes the redeem screen.
    func showRedeem(userID: UUID) {
        let viewModel = RedeemViewModel(loyaltyService: loyaltyService, userID: userID)
        viewModel.coordinator = self
        let vc = RedeemViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
