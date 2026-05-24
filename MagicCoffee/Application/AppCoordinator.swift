import UIKit

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var parent: (any Coordinator)? = nil
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        route()
    }

    private func route() {
        let context = CoreDataStack.shared.viewContext
        let request = CDUser.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        let hasUser = (try? context.fetch(request).first) != nil

        if !hasUser {
            showAuthPlaceholder()
        } else if !UserDefaults.standard.bool(forKey: "mc_store_selected") {
            showStoreSelectionPlaceholder()
        } else {
            showMainTabPlaceholder()
        }
    }

    private func showAuthPlaceholder() {
        let vc = UIViewController()
        vc.view.backgroundColor = .mcPrimary
        navigationController.setViewControllers([vc], animated: false)
    }

    private func showStoreSelectionPlaceholder() {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor(hex: "#1C2B33")
        navigationController.setViewControllers([vc], animated: false)
    }

    private func showMainTabPlaceholder() {
        let vc = UIViewController()
        vc.view.backgroundColor = .mcSurface
        navigationController.setViewControllers([vc], animated: false)
    }
}
