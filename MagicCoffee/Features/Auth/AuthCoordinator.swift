import UIKit

protocol AuthCoordinatorDelegate: AnyObject {
    func authCoordinatorDidFinish(_ coordinator: AuthCoordinator)
}

final class AuthCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var parent: (any Coordinator)?
    weak var delegate: AuthCoordinatorDelegate?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = SplashViewModel()
        viewModel.coordinator = self
        let vc = SplashViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
    }

    func showSignIn() {
        let viewModel = SignInViewModel()
        viewModel.coordinator = self
        let vc = SignInViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func showSignUp() {
        let viewModel = SignUpViewModel()
        viewModel.coordinator = self
        let vc = SignUpViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func showForgotPassword() {
        let viewModel = ForgotPasswordViewModel()
        viewModel.coordinator = self
        let vc = ForgotPasswordViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func showVerification(email: String) {
        let viewModel = VerificationViewModel(email: email)
        viewModel.coordinator = self
        let vc = VerificationViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    /// Pops back to the sign-in screen (used after forgot-password submission).
    func popToSignIn() {
        if let signIn = navigationController.viewControllers.first(where: { $0 is SignInViewController }) {
            navigationController.popToViewController(signIn, animated: true)
        } else {
            navigationController.popViewController(animated: true)
        }
    }

    func finishAuth() {
        delegate?.authCoordinatorDidFinish(self)
    }
}
