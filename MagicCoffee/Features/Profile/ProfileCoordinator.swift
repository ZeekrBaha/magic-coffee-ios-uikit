import UIKit

final class ProfileCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var parent: (any Coordinator)?

    private let authService: AuthService

    init(
        navigationController: UINavigationController,
        authService: AuthService = .shared
    ) {
        self.navigationController = navigationController
        self.authService = authService
    }

    func start() {
        let viewModel = ProfileViewModel(authService: authService)
        viewModel.coordinator = self
        let vc = ProfileViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
    }
}
