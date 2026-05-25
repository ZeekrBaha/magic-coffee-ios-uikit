import XCTest
import CoreData
@testable import MagicCoffee

/// Tests for OrderService fetch methods (ongoing / history).
final class MyOrdersTests: XCTestCase {

    private var stack: CoreDataStack!
    private var authService: AuthService!
    private var service: OrderService!

    private var userA: CDUser!
    private var userB: CDUser!
    private var store: CDStore!

    override func setUpWithError() throws {
        let container = TestCoreDataSupport.makeInMemoryContainer()
        stack = CoreDataStack(container: container)
        authService = AuthService(stack: stack)
        service = OrderService(stack: stack, authService: authService)

        let ctx = stack.viewContext

        // Seed two users.
        userA = CDUser(context: ctx)
        userA.id = UUID()
        userA.name = "User A"
        userA.email = "a@mc.com"
        userA.passwordHash = ""
        userA.isActive = false

        userB = CDUser(context: ctx)
        userB.id = UUID()
        userB.name = "User B"
        userB.email = "b@mc.com"
        userB.passwordHash = ""
        userB.isActive = false

        // Seed a store.
        store = CDStore(context: ctx)
        store.id = UUID()
        store.name = "Test Store"
        store.address = "123 Test St"
        store.latitude = 0
        store.longitude = 0

        try ctx.save()
    }

    override func tearDownWithError() throws {
        service = nil
        authService = nil
        stack = nil
        userA = nil
        userB = nil
        store = nil
    }

    // MARK: - Helpers

    /// Insert a CDOrder into the viewContext without saving.
    @discardableResult
    private func makeOrder(
        user: CDUser,
        status: String,
        totalAmount: Double = 3.50
    ) -> CDOrder {
        let ctx = stack.viewContext
        let order = CDOrder(context: ctx)
        order.id = UUID()
        order.status = status
        order.totalAmount = NSDecimalNumber(value: totalAmount)
        order.createdAt = Date()
        order.pickupCode = "ABC123"
        order.isOnsite = true
        order.user = user
        order.store = store
        return order
    }

    /// Insert one order and save immediately.
    @discardableResult
    private func seedOrder(
        user: CDUser,
        status: String,
        totalAmount: Double = 3.50
    ) throws -> CDOrder {
        let order = makeOrder(user: user, status: status, totalAmount: totalAmount)
        try stack.viewContext.save()
        return order
    }

    /// Insert multiple orders in one save to avoid dangling-reference validation issues.
    private func seedOrders(_ specs: [(user: CDUser, status: String)]) throws {
        for spec in specs {
            makeOrder(user: spec.user, status: spec.status)
        }
        try stack.viewContext.save()
    }

    // MARK: - fetchOngoingOrders

    func testFetchOngoingReturnsOnlyOngoingOrders() async throws {
        let userID = userA.id!
        try seedOrders([(userA, "ongoing"), (userA, "completed")])

        let results = try await service.fetchOngoingOrders(for: userID)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.status, "ongoing")
    }

    func testFetchHistoryReturnsOnlyCompletedOrders() async throws {
        let userID = userA.id!
        try seedOrders([(userA, "ongoing"), (userA, "completed")])

        let results = try await service.fetchHistoryOrders(for: userID)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.status, "completed")
    }

    func testFetchOngoingEmptyForNewUser() async throws {
        // userB has no orders at all
        let userID = userB.id!
        let results = try await service.fetchOngoingOrders(for: userID)
        XCTAssertTrue(results.isEmpty)
    }

    func testFetchHistoryEmptyForNewUser() async throws {
        let userID = userB.id!
        let results = try await service.fetchHistoryOrders(for: userID)
        XCTAssertTrue(results.isEmpty)
    }

    func testFetchOngoingOrdersFiltersByUser() async throws {
        // Seed an ongoing order for userA only.
        try seedOrder(user: userA, status: "ongoing")

        // Fetching for userB should return nothing.
        let userBID = userB.id!
        let results = try await service.fetchOngoingOrders(for: userBID)
        XCTAssertTrue(results.isEmpty, "userB should not see userA's orders")
    }
}
