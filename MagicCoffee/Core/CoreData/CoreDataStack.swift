import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    /// Single model instance shared by every container in the process (production and
    /// tests alike). Loading the model more than once registers the same
    /// NSManagedObject subclasses against multiple NSManagedObjectModels, which makes
    /// `+entity` unable to disambiguate and crashes `init(context:)` nondeterministically.
    static let managedObjectModel: NSManagedObjectModel = {
        guard
            let url = Bundle(for: CoreDataStack.self).url(forResource: "MagicCoffee", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url)
        else {
            fatalError("Cannot load MagicCoffee.momd from bundle")
        }
        return model
    }()

    private let injectedContainer: NSPersistentContainer?

    private init() {
        self.injectedContainer = nil
    }

    /// Test-only initializer that lets callers inject a pre-built (e.g. in-memory)
    /// container so `AuthService` and other consumers can run against isolated stores.
    init(container: NSPersistentContainer) {
        self.injectedContainer = container
    }

    lazy var container: NSPersistentContainer = {
        if let injectedContainer { return injectedContainer }
        let container = NSPersistentContainer(name: "MagicCoffee", managedObjectModel: Self.managedObjectModel)
        container.loadPersistentStores { _, error in
            if let error { fatalError("Core Data failed to load: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var viewContext: NSManagedObjectContext { container.viewContext }

    func performBackgroundTask<T>(
        _ block: @escaping (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { context in
                do {
                    let result = try block(context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func save(_ context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
