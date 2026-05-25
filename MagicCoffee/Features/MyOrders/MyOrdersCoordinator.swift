import UIKit

final class MyOrdersCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var parent: (any Coordinator)?

    private let orderService: OrderService

    init(navigationController: UINavigationController, orderService: OrderService = .shared) {
        self.navigationController = navigationController
        self.orderService = orderService
    }

    func start() {
        let vc = MyOrdersViewController(orderService: orderService)
        navigationController.setViewControllers([vc], animated: false)
    }
}
