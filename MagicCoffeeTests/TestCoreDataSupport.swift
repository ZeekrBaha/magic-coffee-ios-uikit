import CoreData
@testable import MagicCoffee

/// Shared helper for building isolated in-memory Core Data stacks in tests.
///
/// Note: Core Data may log benign "Failed to find a unique match for an
/// NSEntityDescription" warnings when a test container coexists with the app's
/// own model inside the test host. The warnings are cosmetic — the in-memory
/// store and the generated `NSManagedObject` subclasses behave correctly.
enum TestCoreDataSupport {
    /// Builds an in-memory container for the MagicCoffee model.
    static func makeInMemoryContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "MagicCoffee")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error { fatalError(error.localizedDescription) }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }
}
