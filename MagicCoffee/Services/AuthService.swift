import CoreData
import CryptoKit
import Foundation

/// Handles user registration, login, session lookup, and logout against Core Data.
///
/// Injectable via `init(stack:)` so tests can supply an in-memory `CoreDataStack`.
final class AuthService {
    static let shared = AuthService()

    private let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
    }

    // MARK: - Password Hashing

    static func hash(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Register

    /// Creates a new active user. Throws `AuthError.emailAlreadyInUse` if the email is taken.
    func register(email: String, password: String, address: String?) async throws {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let passwordHash = Self.hash(password)

        try await stack.performBackgroundTask { context in
            let request = CDUser.fetchRequest()
            request.predicate = NSPredicate(format: "email ==[c] %@", normalizedEmail)
            request.fetchLimit = 1
            if try context.count(for: request) > 0 {
                throw AuthError.emailAlreadyInUse
            }

            let user = CDUser(context: context)
            user.id = UUID()
            user.name = ""
            user.email = normalizedEmail
            user.passwordHash = passwordHash
            user.address = address
            user.isActive = true

            try context.save()
        }
    }

    // MARK: - Login

    /// Fetches the user by email, verifies the password hash, marks them active.
    /// Throws `AuthError.invalidCredentials` on mismatch or unknown email.
    @discardableResult
    func login(email: String, password: String) async throws -> CDUser {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let passwordHash = Self.hash(password)

        let objectID = try await stack.performBackgroundTask { context -> NSManagedObjectID in
            let request = CDUser.fetchRequest()
            request.predicate = NSPredicate(format: "email ==[c] %@", normalizedEmail)
            request.fetchLimit = 1
            guard let user = try context.fetch(request).first else {
                throw AuthError.invalidCredentials
            }
            guard user.passwordHash == passwordHash else {
                throw AuthError.invalidCredentials
            }
            user.isActive = true
            try context.save()
            return user.objectID
        }

        return try await MainActor.run {
            guard let user = try? stack.viewContext.existingObject(with: objectID) as? CDUser else {
                throw AuthError.invalidCredentials
            }
            stack.viewContext.refresh(user, mergeChanges: true)
            return user
        }
    }

    // MARK: - Current User

    /// Returns the first active user from the view context, if any.
    func currentUser() -> CDUser? {
        let request = CDUser.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        request.fetchLimit = 1
        return try? stack.viewContext.fetch(request).first
    }

    // MARK: - Update Profile

    /// Updates mutable fields of the current active user synchronously on the view context.
    /// Silently no-ops if no user is active.
    func updateCurrentUser(name: String, phone: String?, email: String, address: String?) {
        guard let user = currentUser() else { return }
        user.name    = name.isEmpty ? nil : name
        user.phone   = phone
        user.email   = email.isEmpty ? nil : email
        user.address = address
        try? stack.viewContext.save()
    }

    // MARK: - Logout

    /// Deactivates all active users.
    func logout() async throws {
        try await stack.performBackgroundTask { context in
            let request = CDUser.fetchRequest()
            request.predicate = NSPredicate(format: "isActive == YES")
            let users = try context.fetch(request)
            for user in users {
                user.isActive = false
            }
            try context.save()
        }
    }
}
