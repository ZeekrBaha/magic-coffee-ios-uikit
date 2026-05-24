import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    private init() {}

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MagicCoffee")
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
