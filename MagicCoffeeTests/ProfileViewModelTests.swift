import XCTest
import CoreData
@testable import MagicCoffee

final class ProfileViewModelTests: XCTestCase {
    private var stack: CoreDataStack!
    private var authService: AuthService!

    override func setUpWithError() throws {
        let container = TestCoreDataSupport.makeInMemoryContainer()
        stack = CoreDataStack(container: container)
        authService = AuthService(stack: stack)
    }

    override func tearDownWithError() throws {
        authService = nil
        stack = nil
    }

    // MARK: - Helpers

    private func seedUser(
        name: String = "Alice",
        email: String = "alice@example.com",
        phone: String? = "555-1234",
        address: String? = "123 Main St"
    ) async throws {
        try await authService.register(email: email, password: "pass", address: address)
        // Patch name and phone directly since register doesn't accept them
        let user = authService.currentUser()!
        user.name = name
        user.phone = phone
        try stack.viewContext.save()
    }

    private func makeViewModel() -> ProfileViewModel {
        ProfileViewModel(authService: authService)
    }

    // MARK: - Tests

    func testProfileLoadsCurrentUser() async throws {
        try await seedUser(name: "Alice", email: "alice@example.com", phone: "555-1234", address: "123 Main St")

        let vm = makeViewModel()
        vm.loadUser()

        XCTAssertEqual(vm.name, "Alice")
        XCTAssertEqual(vm.email, "alice@example.com")
        XCTAssertEqual(vm.phone, "555-1234")
        XCTAssertEqual(vm.address, "123 Main St")
    }

    func testSaveUpdatesUserName() async throws {
        try await seedUser(name: "Alice", email: "alice@example.com")

        let vm = makeViewModel()
        vm.loadUser()
        vm.name = "Bob"
        vm.save()

        // Reload from Core Data to confirm persistence
        stack.viewContext.reset()
        let updated = authService.currentUser()
        XCTAssertEqual(updated?.name, "Bob")
    }

    func testSaveUpdatesUserPhone() async throws {
        try await seedUser(email: "alice@example.com", phone: "555-1234")

        let vm = makeViewModel()
        vm.loadUser()
        vm.phone = "999-9999"
        vm.save()

        stack.viewContext.reset()
        let updated = authService.currentUser()
        XCTAssertEqual(updated?.phone, "999-9999")
    }

    func testSaveUpdatesUserEmail() async throws {
        try await seedUser(email: "alice@example.com")

        let vm = makeViewModel()
        vm.loadUser()
        vm.email = "new@example.com"
        vm.save()

        stack.viewContext.reset()
        let updated = authService.currentUser()
        XCTAssertEqual(updated?.email, "new@example.com")
    }

    func testSaveUpdatesUserAddress() async throws {
        try await seedUser(email: "alice@example.com", address: "123 Main St")

        let vm = makeViewModel()
        vm.loadUser()
        vm.address = "456 Oak Ave"
        vm.save()

        stack.viewContext.reset()
        let updated = authService.currentUser()
        XCTAssertEqual(updated?.address, "456 Oak Ave")
    }

    func testSaveWithNoCurrentUserDoesNotCrash() {
        // No user seeded — currentUser() returns nil
        let vm = makeViewModel()
        vm.loadUser()
        vm.name = "Ghost"
        // Must not crash
        vm.save()
        // No user in store — nothing to assert beyond no crash
        XCTAssertNil(authService.currentUser())
    }
}
