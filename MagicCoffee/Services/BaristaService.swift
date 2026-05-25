import CoreData
import Foundation

/// Fetches barista data from Core Data. Injectable via `init(stack:)` for testing.
final class BaristaService {
    static let shared = BaristaService()

    private let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
    }

    /// Returns all CDBarista objects sorted by name, fetched on a background context.
    func fetchAll() async throws -> [CDBarista] {
        let objectIDs: [NSManagedObjectID] = try await stack.performBackgroundTask { context in
            let request = CDBarista.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let baristas = try context.fetch(request)
            return baristas.map { $0.objectID }
        }

        return await MainActor.run {
            objectIDs.compactMap { id in
                try? stack.viewContext.existingObject(with: id) as? CDBarista
            }
        }
    }
}
