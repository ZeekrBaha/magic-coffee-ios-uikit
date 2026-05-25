import XCTest
import CoreData
@testable import MagicCoffee

final class BaristaServiceTests: XCTestCase {

    private var stack: CoreDataStack!
    private var service: BaristaService!

    override func setUpWithError() throws {
        let container = TestCoreDataSupport.makeInMemoryContainer()
        stack = CoreDataStack(container: container)
        service = BaristaService(stack: stack)
        // Seed 3 baristas: Victor (available), Andrey (available), Sofia (unavailable)
        DataSeeder.seedBaristas(in: stack.viewContext)
        try stack.viewContext.save()
    }

    override func tearDownWithError() throws {
        service = nil
        stack = nil
    }

    func testFetchAllReturnsThreeBaristas() async throws {
        let baristas = try await service.fetchAll()
        XCTAssertEqual(baristas.count, 3, "Expected 3 seeded baristas")
    }

    func testFetchAllBaristasHaveNonNilIDs() async throws {
        let baristas = try await service.fetchAll()
        for barista in baristas {
            XCTAssertNotNil(barista.id, "Barista id should not be nil")
        }
    }

    func testFetchAllBaristasHaveNonEmptyNames() async throws {
        let baristas = try await service.fetchAll()
        for barista in baristas {
            XCTAssertFalse(barista.name?.isEmpty ?? true, "Barista name should not be empty")
        }
    }

    func testAvailableBaristasCount() async throws {
        let baristas = try await service.fetchAll()
        let available = baristas.filter { $0.isAvailable }
        XCTAssertEqual(available.count, 2, "Expected 2 available baristas (Victor and Andrey)")
    }

    func testBaristaServiceOnEmptyStore() async throws {
        let emptyContainer = TestCoreDataSupport.makeInMemoryContainer()
        let emptyStack = CoreDataStack(container: emptyContainer)
        let emptyService = BaristaService(stack: emptyStack)
        let baristas = try await emptyService.fetchAll()
        XCTAssertTrue(baristas.isEmpty, "Should return empty array when no baristas are seeded")
    }
}
