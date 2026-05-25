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
            showAuth()
        } else if !UserDefaults.standard.bool(forKey: "mc_store_selected") {
            showStoreSelection()
        } else {
            showMainTab()
        }
    }

    private func showAuth() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.parent = self
        authCoordinator.delegate = self
        addChild(authCoordinator)
        authCoordinator.start()
    }

    private func showStoreSelection() {
        let storeCoordinator = StoreSelectionCoordinator(navigationController: navigationController)
        storeCoordinator.parent = self
        storeCoordinator.delegate = self
        addChild(storeCoordinator)
        storeCoordinator.start()
    }

    private func showMainTab() {
        let tabCoordinator = MainTabCoordinator(navigationController: navigationController)
        tabCoordinator.parent = self
        addChild(tabCoordinator)
        tabCoordinator.start()
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func authCoordinatorDidFinish(_ coordinator: AuthCoordinator) {
        removeChild(coordinator)
        showStoreSelection()
    }
}

extension AppCoordinator: StoreSelectionCoordinatorDelegate {
    func storeSelectionCoordinatorDidFinish(_ coordinator: StoreSelectionCoordinator) {
        removeChild(coordinator)
        showMainTab()
    }
}
