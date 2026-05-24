import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [any Coordinator] { get set }
    var parent: (any Coordinator)? { get set }
    func start()
    func finish()
}

extension Coordinator {
    func addChild(_ coordinator: any Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }

    func finish() {
        parent?.removeChild(self)
    }
}
