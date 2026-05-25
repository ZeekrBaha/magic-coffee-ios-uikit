import CoreData
import Foundation

/// Fetches product data from Core Data. Injectable via `init(stack:)` for testing.
final class ProductService {
    static let shared = ProductService()

    private let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
    }

    /// Returns all CDProduct objects sorted by sortOrder, fetched on a background context.
    func fetchAll() async throws -> [CDProduct] {
        let objectIDs: [NSManagedObjectID] = try await stack.performBackgroundTask { context in
            let request = CDProduct.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
            let products = try context.fetch(request)
            return products.map { $0.objectID }
        }

        return await MainActor.run {
            objectIDs.compactMap { id in
                try? stack.viewContext.existingObject(with: id) as? CDProduct
            }
        }
    }
}
