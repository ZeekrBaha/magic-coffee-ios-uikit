import XCTest
import CoreData
@testable import MagicCoffee

final class ProductServiceTests: XCTestCase {
    private var stack: CoreDataStack!
    private var service: ProductService!

    override func setUpWithError() throws {
        let container = TestCoreDataSupport.makeInMemoryContainer()
        stack = CoreDataStack(container: container)
        service = ProductService(stack: stack)
        // Seed 6 products directly into the view context
        DataSeeder.seedProducts(in: stack.viewContext)
        try stack.viewContext.save()
    }

    override func tearDownWithError() throws {
        service = nil
        stack = nil
    }

    func testFetchAllReturnsSixProducts() async throws {
        let products = try await service.fetchAll()
        XCTAssertEqual(products.count, 6, "Expected 6 seeded products")
    }

    func testFetchAllSortedBySortOrder() async throws {
        let products = try await service.fetchAll()
        let orders = products.map { $0.sortOrder }
        XCTAssertEqual(orders, orders.sorted(), "Products should be sorted by sortOrder ascending")
    }

    func testProductsHaveNonNilIDs() async throws {
        let products = try await service.fetchAll()
        for product in products {
            XCTAssertNotNil(product.id, "Product id should not be nil")
        }
    }

    func testProductsHaveNonEmptyNames() async throws {
        let products = try await service.fetchAll()
        for product in products {
            XCTAssertFalse(product.name?.isEmpty ?? true, "Product name should not be empty")
        }
    }

    func testProductsHavePositivePrices() async throws {
        let products = try await service.fetchAll()
        for product in products {
            let price = product.price?.decimalValue ?? 0
            XCTAssertGreaterThan(price, 0, "Product price should be positive")
        }
    }

    func testEmptyStoreReturnsEmpty() async throws {
        let emptyContainer = TestCoreDataSupport.makeInMemoryContainer()
        let emptyStack = CoreDataStack(container: emptyContainer)
        let emptyService = ProductService(stack: emptyStack)
        let products = try await emptyService.fetchAll()
        XCTAssertTrue(products.isEmpty, "Should return empty array when no products are seeded")
    }
}
