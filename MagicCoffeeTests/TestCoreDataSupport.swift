import CoreData
@testable import MagicCoffee

/// Shared helper for building isolated in-memory Core Data stacks in tests.
///
/// Uses a single shared NSManagedObjectModel so NSManagedObject subclasses are
/// registered only once. Loading a fresh model per container causes Core Data to
/// register the same subclasses multiple times, which triggers "Multiple
/// NSEntityDescriptions" warnings and can crash when entity lookup is ambiguous.
enum TestCoreDataSupport {

    /// Builds an isolated in-memory container that reuses the process-wide single model.
    ///
    /// Reusing `CoreDataStack.managedObjectModel` (rather than loading a fresh model
    /// here) guarantees the test host app's default stack and every test container all
    /// share one NSManagedObjectModel, so `+entity` never has multiple models to
    /// disambiguate between.
    static func makeInMemoryContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(
            name: "MagicCoffee",
            managedObjectModel: CoreDataStack.managedObjectModel
        )
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
