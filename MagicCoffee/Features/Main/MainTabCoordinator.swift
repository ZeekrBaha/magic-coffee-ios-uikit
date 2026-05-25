import UIKit

final class MainTabCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var parent: (any Coordinator)?

    private let tabBarController: UITabBarController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
    }

    func start() {
        setupTabBar()
        navigationController.setViewControllers([tabBarController], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Private

    private func setupTabBar() {
        tabBarController.tabBar.tintColor = .mcAccent
        tabBarController.tabBar.unselectedItemTintColor = UIColor.mcPrimary.withAlphaComponent(0.4)
        tabBarController.tabBar.backgroundColor = .mcSurface

        // Tab 0: Catalog (CatalogCoordinator owns its own nav controller)
        let catalogNav = UINavigationController()
        let catalogCoordinator = CatalogCoordinator(navigationController: catalogNav)
        catalogCoordinator.parent = self
        addChild(catalogCoordinator)
        catalogCoordinator.start()
        catalogNav.tabBarItem = UITabBarItem(
            title: "Catalog",
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )

        // Tab 1: Rewards (RewardsCoordinator)
        let rewardsNav = UINavigationController()
        let rewardsCoordinator = RewardsCoordinator(navigationController: rewardsNav)
        rewardsCoordinator.parent = self
        addChild(rewardsCoordinator)
        rewardsCoordinator.start()
        rewardsNav.tabBarItem = UITabBarItem(
            title: "Rewards",
            image: UIImage(systemName: "gift.fill"),
            tag: 1
        )

        // Tab 2: My Orders (MyOrdersCoordinator)
        let ordersNav = UINavigationController()
        let myOrdersCoordinator = MyOrdersCoordinator(navigationController: ordersNav)
        myOrdersCoordinator.parent = self
        addChild(myOrdersCoordinator)
        myOrdersCoordinator.start()
        ordersNav.tabBarItem = UITabBarItem(
            title: "My Orders",
            image: UIImage(systemName: "list.bullet.rectangle.fill"),
            tag: 2
        )

        // Tab 3: Profile (ProfileCoordinator)
        let profileNav = UINavigationController()
        let profileCoordinator = ProfileCoordinator(navigationController: profileNav)
        profileCoordinator.parent = self
        addChild(profileCoordinator)
        profileCoordinator.start()
        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.crop.circle"),
            tag: 3
        )

        tabBarController.viewControllers = [catalogNav, rewardsNav, ordersNav, profileNav]
    }
}
