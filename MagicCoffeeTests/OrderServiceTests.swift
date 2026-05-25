import XCTest
import CoreData
@testable import MagicCoffee

final class OrderServiceTests: XCTestCase {

    private var stack: CoreDataStack!
    private var authService: AuthService!
    private var service: OrderService!

    // Seeded entities reused across tests.
    private var product: CDProduct!
    private var store: CDStore!
    private var state: AssemblageState!

    override func setUpWithError() throws {
        let container = TestCoreDataSupport.makeInMemoryContainer()
        stack = CoreDataStack(container: container)
        authService = AuthService(stack: stack)
        service = OrderService(stack: stack, authService: authService)

        // Seed a product.
        let ctx = stack.viewContext
        let p = CDProduct(context: ctx)
        p.id = UUID()
        p.name = "Latte"
        p.price = NSDecimalNumber(value: 3.50)
        p.sortOrder = 0
        p.imagePath = ""
        product = p

        // Seed a store.
        let s = CDStore(context: ctx)
        s.id = UUID()
        s.name = "Bradford 804 914"
        s.address = "Bradford BD1"
        s.latitude = 53.79
        s.longitude = -1.75
        store = s

        try ctx.save()

        // Build assemblage state.
        state = AssemblageState()
        state.selectedProduct = product
        state.milkType = "Oat"
        state.syrupType = "Vanilla"
        state.selectedAdditives = ["Cinnamon"]
        state.isOnsite = true
    }

    override func tearDownWithError() throws {
        service = nil
        authService = nil
        stack = nil
        product = nil
        store = nil
        state = nil
    }

    // MARK: - Helpers

    private func seedActiveUser() async throws {
        try await authService.register(email: "test@mc.com", password: "pw123", address: "Bradford")
    }

    // MARK: - Tests

    func testPlaceOrderCreatesOrder() async throws {
        try await seedActiveUser()
        let storeID = store.id!

        let order = try await service.placeOrder(
            product: product,
            state: state,
            storeID: storeID,
            paymentMethod: "card"
        )

        XCTAssertNotNil(order.id, "Order should have an id")
        XCTAssertEqual(order.status, "ongoing", "Status should be 'ongoing'")
        XCTAssertNotNil(order.createdAt, "createdAt should be set")
    }

    func testPlaceOrderCreatesOrderItem() async throws {
        try await seedActiveUser()
        let storeID = store.id!

        let order = try await service.placeOrder(
            product: product,
            state: state,
            storeID: storeID,
            paymentMethod: "card"
        )

        let items = order.items as? Set<CDOrderItem> ?? []
        XCTAssertEqual(items.count, 1, "Order should have exactly 1 item")
        let item = try XCTUnwrap(items.first)
        XCTAssertEqual(item.quantity, 1)
        XCTAssertEqual(item.product?.id, product.id, "Item should link to the ordered product")
    }

    func testPlaceOrderIncrementsLoyaltyStamp() async throws {
        try await seedActiveUser()
        let storeID = store.id!

        _ = try await service.placeOrder(
            product: product,
            state: state,
            storeID: storeID,
            paymentMethod: "online"
        )

        // Reload the user's loyalty card from the view context.
        let userRequest = CDUser.fetchRequest()
        userRequest.predicate = NSPredicate(format: "isActive == YES")
        userRequest.fetchLimit = 1
        stack.viewContext.refreshAllObjects()
        let user = try stack.viewContext.fetch(userRequest).first
        let card = try XCTUnwrap(user?.loyaltyCard, "User should have a loyalty card after ordering")
        XCTAssertEqual(card.stamps, 1, "Stamps should be incremented to 1")
    }

    func testPlaceOrderLinksToUser() async throws {
        try await seedActiveUser()
        let storeID = store.id!
        let currentUser = try XCTUnwrap(authService.currentUser())

        let order = try await service.placeOrder(
            product: product,
            state: state,
            storeID: storeID,
            paymentMethod: "card"
        )

        stack.viewContext.refresh(order, mergeChanges: true)
        XCTAssertEqual(order.user?.id, currentUser.id, "Order should be linked to the active user")
    }

    func testPlaceOrderLinksToStore() async throws {
        try await seedActiveUser()
        let storeID = store.id!

        let order = try await service.placeOrder(
            product: product,
            state: state,
            storeID: storeID,
            paymentMethod: "card"
        )

        stack.viewContext.refresh(order, mergeChanges: true)
        XCTAssertEqual(order.store?.id, storeID, "Order should be linked to the specified store")
    }

    func testPlaceOrderSetsTotalAmount() async throws {
        try await seedActiveUser()
        let storeID = store.id!

        let order = try await service.placeOrder(
            product: product,
            state: state,
            storeID: storeID,
            paymentMethod: "card"
        )

        let expectedAmount = NSDecimalNumber(value: 3.50)
        XCTAssertEqual(order.totalAmount, expectedAmount, "totalAmount should match product price")
    }

    func testPlaceOrderThrowsWithNoActiveUser() async throws {
        // No user registered → should throw noActiveUser
        let storeID = store.id!

        do {
            _ = try await service.placeOrder(
                product: product,
                state: state,
                storeID: storeID,
                paymentMethod: "card"
            )
            XCTFail("Expected noActiveUser error")
        } catch let error as OrderServiceError {
            XCTAssertEqual(error, .noActiveUser)
        }
    }
}
