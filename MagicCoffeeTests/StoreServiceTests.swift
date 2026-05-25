import XCTest
import CoreData
@testable import MagicCoffee

final class StoreServiceTests: XCTestCase {
    private var stack: CoreDataStack!
    private var service: StoreService!

    override func setUpWithError() throws {
        let container = TestCoreDataSupport.makeInMemoryContainer()
        stack = CoreDataStack(container: container)
        service = StoreService(stack: stack)
        // Seed three stores directly into the view context for deterministic tests
        DataSeeder.seedStores(in: stack.viewContext)
        try stack.viewContext.save()
    }

    override func tearDownWithError() throws {
        service = nil
        stack = nil
    }

    func testFetchAllReturnsThreeStores() async throws {
        let stores = try await service.fetchAll()
        XCTAssertEqual(stores.count, 3, "Expected 3 seeded stores")
    }

    func testFetchAllStoresHaveNonNilIDs() async throws {
        let stores = try await service.fetchAll()
        for store in stores {
            XCTAssertNotNil(store.id, "Store id should not be nil")
        }
    }

    func testFetchAllStoresHaveNonEmptyNames() async throws {
        let stores = try await service.fetchAll()
        for store in stores {
            XCTAssertFalse(store.name?.isEmpty ?? true, "Store name should not be empty")
        }
    }

    func testFetchAllStoresHaveNonEmptyAddresses() async throws {
        let stores = try await service.fetchAll()
        for store in stores {
            XCTAssertFalse(store.address?.isEmpty ?? true, "Store address should not be empty")
        }
    }

    func testFetchAllReturnsSortedByName() async throws {
        let stores = try await service.fetchAll()
        let names = stores.compactMap { $0.name }
        XCTAssertEqual(names, names.sorted(), "Stores should be returned sorted by name")
    }

    func testFetchAllStoresHaveValidCoordinates() async throws {
        let stores = try await service.fetchAll()
        for store in stores {
            XCTAssertGreaterThan(store.latitude, 50, "Latitude should be in UK range (>50)")
            XCTAssertLessThan(store.latitude, 56, "Latitude should be in UK range (<56)")
        }
    }

    func testFetchAllOnEmptyStoreReturnsEmpty() async throws {
        // Create a fresh empty stack
        let emptyContainer = TestCoreDataSupport.makeInMemoryContainer()
        let emptyStack = CoreDataStack(container: emptyContainer)
        let emptyService = StoreService(stack: emptyStack)
        let stores = try await emptyService.fetchAll()
        XCTAssertTrue(stores.isEmpty, "Should return empty array when no stores are seeded")
    }
}
