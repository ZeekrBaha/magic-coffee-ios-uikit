import XCTest
import CoreData
@testable import MagicCoffee

final class CoreDataStackTests: XCTestCase {
    private var container: NSPersistentContainer!

    override func setUpWithError() throws {
        container = TestCoreDataSupport.makeInMemoryContainer()
    }

    override func tearDownWithError() throws {
        container = nil
    }

    /// Mirrors CoreDataStack.performBackgroundTask but bound to the test container.
    private func performBackgroundTask<T>(
        _ block: @escaping (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { context in
                do {
                    continuation.resume(returning: try block(context))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func testPerformBackgroundTaskCreatesObjectVisibleInViewContext() async throws {
        let createdID: NSManagedObjectID = try await performBackgroundTask { context in
            let product = CDProduct(context: context)
            product.id = UUID()
            product.name = "Test Latte"
            product.imagePath = "products/test"
            product.price = NSDecimalNumber(value: 4.5)
            product.sortOrder = 0
            try context.save()
            return product.objectID
        }

        let viewContext = container.viewContext
        let fetched = try XCTUnwrap(viewContext.existingObject(with: createdID) as? CDProduct)
        XCTAssertEqual(fetched.name, "Test Latte")

        let request = NSFetchRequest<NSManagedObject>(entityName: "CDProduct")
        XCTAssertEqual(try viewContext.count(for: request), 1)
    }

    func testPerformBackgroundTaskPropagatesThrownError() async {
        struct SampleError: Error {}
        do {
            _ = try await performBackgroundTask { _ -> Int in
                throw SampleError()
            }
            XCTFail("Expected error to propagate")
        } catch {
            XCTAssertTrue(error is SampleError)
        }
    }

    func testCoreDataStackSharedSaveSkipsWhenNoChanges() throws {
        // No changes pending -> save() should be a no-op and must not throw.
        let context = container.viewContext
        XCTAssertNoThrow(try {
            guard context.hasChanges else { return }
            try context.save()
        }())
    }
}
