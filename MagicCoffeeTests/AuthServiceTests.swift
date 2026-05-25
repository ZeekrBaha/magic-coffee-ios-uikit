import XCTest
import CoreData
@testable import MagicCoffee

final class AuthServiceTests: XCTestCase {
    private var stack: CoreDataStack!
    private var service: AuthService!

    override func setUpWithError() throws {
        let container = TestCoreDataSupport.makeInMemoryContainer()
        stack = CoreDataStack(container: container)
        service = AuthService(stack: stack)
    }

    override func tearDownWithError() throws {
        service = nil
        stack = nil
    }

    func testRegisterCreatesUser() async throws {
        try await service.register(email: "a@b.com", password: "secret", address: "Bradford")

        let request = CDUser.fetchRequest()
        let users = try stack.viewContext.fetch(request)
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users.first?.email, "a@b.com")
        XCTAssertEqual(users.first?.address, "Bradford")
        XCTAssertEqual(users.first?.isActive, true)
        XCTAssertNotEqual(users.first?.passwordHash, "secret", "Password should be hashed, not stored raw")
    }

    func testRegisterThrowsOnDuplicateEmail() async throws {
        try await service.register(email: "dup@b.com", password: "secret", address: nil)

        do {
            try await service.register(email: "dup@b.com", password: "other", address: nil)
            XCTFail("Expected emailAlreadyInUse error")
        } catch let error as AuthError {
            XCTAssertEqual(error, .emailAlreadyInUse)
        }
    }

    func testLoginSucceeds() async throws {
        try await service.register(email: "login@b.com", password: "secret", address: nil)
        // register marks active; reset to verify login flips it back on
        try await service.logout()

        let user = try await service.login(email: "login@b.com", password: "secret")
        XCTAssertEqual(user.email, "login@b.com")
        XCTAssertEqual(user.isActive, true)
    }

    func testLoginFailsWithWrongPassword() async throws {
        try await service.register(email: "wrongpw@b.com", password: "secret", address: nil)

        do {
            _ = try await service.login(email: "wrongpw@b.com", password: "nope")
            XCTFail("Expected invalidCredentials error")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidCredentials)
        }
    }

    func testLoginFailsWithUnknownEmail() async throws {
        do {
            _ = try await service.login(email: "ghost@b.com", password: "secret")
            XCTFail("Expected invalidCredentials error")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidCredentials)
        }
    }

    func testCurrentUserReturnsActiveUser() async throws {
        XCTAssertNil(service.currentUser())
        try await service.register(email: "active@b.com", password: "secret", address: nil)
        let current = service.currentUser()
        XCTAssertNotNil(current)
        XCTAssertEqual(current?.email, "active@b.com")
    }

    func testLogoutDeactivatesUser() async throws {
        try await service.register(email: "out@b.com", password: "secret", address: nil)
        XCTAssertNotNil(service.currentUser())

        try await service.logout()
        stack.viewContext.reset()
        XCTAssertNil(service.currentUser())
    }
}
