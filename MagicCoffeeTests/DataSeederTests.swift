import XCTest
import CoreData
@testable import MagicCoffee

final class DataSeederTests: XCTestCase {
    private var container: NSPersistentContainer!
    private let seededKey = "mc_seeded"

    override func setUpWithError() throws {
        container = TestCoreDataSupport.makeInMemoryContainer()
        UserDefaults.standard.removeObject(forKey: seededKey)
    }

    override func tearDownWithError() throws {
        container = nil
        UserDefaults.standard.removeObject(forKey: seededKey)
    }

    private var context: NSManagedObjectContext { container.viewContext }

    private func count(_ entityName: String) throws -> Int {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        return try context.count(for: request)
    }

    func testSeedIfNeededCreatesSixProducts() throws {
        DataSeeder.seedIfNeeded(in: context)
        XCTAssertEqual(try count("CDProduct"), 6)
    }

    func testSeedIfNeededCreatesThreeStores() throws {
        DataSeeder.seedIfNeeded(in: context)
        XCTAssertEqual(try count("CDStore"), 3)
    }

    func testSeedIfNeededCreatesThreeBaristas() throws {
        DataSeeder.seedIfNeeded(in: context)
        XCTAssertEqual(try count("CDBarista"), 3)
    }

    func testSeedIfNeededIsIdempotent() throws {
        DataSeeder.seedIfNeeded(in: context)
        DataSeeder.seedIfNeeded(in: context)
        XCTAssertEqual(try count("CDProduct"), 6)
        XCTAssertEqual(try count("CDStore"), 3)
        XCTAssertEqual(try count("CDBarista"), 3)
    }

    func testProductSortOrdersAreSequential() throws {
        DataSeeder.seedIfNeeded(in: context)
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDProduct")
        request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        let products = try context.fetch(request)
        let sortOrders = products.map { ($0.value(forKey: "sortOrder") as? Int16) ?? -1 }
        XCTAssertEqual(sortOrders, [0, 1, 2, 3, 4, 5])
    }
}
