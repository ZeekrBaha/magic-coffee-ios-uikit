import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // UI-test hook: force a clean, logged-out state so flows start at Splash.
        if ProcessInfo.processInfo.arguments.contains("-uitest-reset-auth") {
            UserDefaults.standard.removeObject(forKey: "mc_store_selected")
            let context = CoreDataStack.shared.viewContext
            let request = CDUser.fetchRequest()
            request.predicate = NSPredicate(format: "isActive == YES")
            if let users = try? context.fetch(request) {
                users.forEach { $0.isActive = false }
                try? context.save()
            }
        }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let coordinator = AppCoordinator(window: window)
        appCoordinator = coordinator
        coordinator.start()
        // Seed in background after UI is shown
        Task {
            await DataSeeder.seedIfNeeded()
        }
    }
}
