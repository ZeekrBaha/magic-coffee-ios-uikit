import CoreData
import Foundation

/// Fetches store data from Core Data. Injectable via `init(stack:)` for testing.
final class StoreService {
    static let shared = StoreService()

    private let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
    }

    /// Returns all CDStore objects sorted by name, fetched on a background context.
    func fetchAll() async throws -> [CDStore] {
        let objectIDs: [NSManagedObjectID] = try await stack.performBackgroundTask { context in
            let request = CDStore.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let stores = try context.fetch(request)
            return stores.map { $0.objectID }
        }

        return await MainActor.run {
            objectIDs.compactMap { id in
                try? stack.viewContext.existingObject(with: id) as? CDStore
            }
        }
    }
}
