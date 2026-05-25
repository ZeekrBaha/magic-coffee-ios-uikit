import XCTest
import CoreData
@testable import MagicCoffee

final class LoyaltyServiceTests: XCTestCase {

    private var stack: CoreDataStack!
    private var authService: AuthService!
    private var service: LoyaltyService!
    private var testUserID: UUID!

    override func setUpWithError() throws {
        let container = TestCoreDataSupport.makeInMemoryContainer()
        stack = CoreDataStack(container: container)
        authService = AuthService(stack: stack)
        service = LoyaltyService(stack: stack)
        testUserID = UUID()

        // Seed a user directly in the view context so every test has a user.
        let user = CDUser(context: stack.viewContext)
        user.id = testUserID
        user.name = "Test"
        user.email = "test@loyalty.com"
        user.passwordHash = ""
        user.isActive = true
        try stack.viewContext.save()
    }

    override func tearDownWithError() throws {
        service = nil
        authService = nil
        stack = nil
        testUserID = nil
    }

    // MARK: - Tests

    func testFetchLoyaltyCardReturnsNilForNewUser() async throws {
        let card = try await service.fetchLoyaltyCard(for: testUserID)
        XCTAssertNil(card, "A new user should have no loyalty card")
    }

    func testAddStampCreatesCardIfMissing() async throws {
        try await service.addStamp(for: testUserID)

        let card = try await service.fetchLoyaltyCard(for: testUserID)
        XCTAssertNotNil(card, "Card should be created after first stamp")
        XCTAssertEqual(card?.stamps, 1, "Stamps should be 1 after first addStamp")
    }

    func testAddStampIncrementsStamps() async throws {
        try await service.addStamp(for: testUserID)
        try await service.addStamp(for: testUserID)

        let card = try await service.fetchLoyaltyCard(for: testUserID)
        XCTAssertEqual(card?.stamps, 2, "Stamps should be 2 after two addStamp calls")
    }

    func testAddStampResetsAt8AndAddsPoints() async throws {
        // Add 8 stamps — the 8th should trigger a reset.
        for _ in 0..<8 {
            try await service.addStamp(for: testUserID)
        }

        let card = try await service.fetchLoyaltyCard(for: testUserID)
        XCTAssertEqual(card?.stamps, 0, "Stamps should reset to 0 after reaching maxStamps")
        XCTAssertEqual(card?.totalPoints, 500, "500 points should be awarded when stamps max out")
    }

    func testAddPointsIncrementsPoints() async throws {
        try await service.addPoints(100, for: testUserID)

        let card = try await service.fetchLoyaltyCard(for: testUserID)
        XCTAssertEqual(card?.totalPoints, 100, "totalPoints should be 100 after adding 100 points")
    }

    func testRedeemDeductsPoints() async throws {
        try await service.addPoints(300, for: testUserID)
        try await service.redeemReward(name: "Latte", cost: 200, for: testUserID)

        let card = try await service.fetchLoyaltyCard(for: testUserID)
        XCTAssertEqual(card?.totalPoints, 100, "totalPoints should be 100 after redeeming 200 from 300")
    }

    func testRedeemThrowsIfInsufficientPoints() async throws {
        try await service.addPoints(50, for: testUserID)

        do {
            try await service.redeemReward(name: "Flat White", cost: 200, for: testUserID)
            XCTFail("Expected insufficientPoints error")
        } catch let error as LoyaltyServiceError {
            XCTAssertEqual(error, .insufficientPoints)
        }
    }

    func testRedeemRecordsHistory() async throws {
        try await service.addPoints(300, for: testUserID)
        try await service.redeemReward(name: "Cappuccino", cost: 250, for: testUserID)

        let history = try await service.fetchHistory(for: testUserID)
        XCTAssertEqual(history.count, 1, "History should have 1 entry after one redemption")
        XCTAssertEqual(history.first?.productName, "Cappuccino")
        XCTAssertEqual(history.first?.points, 250)
    }
}
