import CoreData
import Foundation

// MARK: - LoyaltyServiceError

enum LoyaltyServiceError: Error, Equatable {
    case insufficientPoints
    case userNotFound
}

// MARK: - LoyaltyService

/// Manages loyalty card state and reward history in Core Data.
/// Injectable via `init(stack:)` for testing.
final class LoyaltyService {
    static let shared = LoyaltyService()

    private let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
    }

    // MARK: - Fetch

    /// Returns the loyalty card for a user, or nil if none exists.
    func fetchLoyaltyCard(for userID: UUID) async throws -> CDLoyaltyCard? {
        let objectID: NSManagedObjectID? = try await stack.performBackgroundTask { context in
            let request = CDUser.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", userID as CVarArg)
            request.fetchLimit = 1
            guard let user = try context.fetch(request).first else { return nil }
            return user.loyaltyCard?.objectID
        }

        guard let objectID else { return nil }
        return await MainActor.run {
            stack.viewContext.object(with: objectID) as? CDLoyaltyCard
        }
    }

    // MARK: - Add Stamp

    /// Increments the stamp count for a user. If no card exists, creates one.
    /// When stamps reach 8, resets stamps to 0 and awards 500 points.
    func addStamp(for userID: UUID) async throws {
        try await stack.performBackgroundTask { context in
            let user = try self.fetchUser(id: userID, in: context)
            let card: CDLoyaltyCard
            if let existing = user.loyaltyCard {
                card = existing
            } else {
                let newCard = CDLoyaltyCard(context: context)
                newCard.id = UUID()
                newCard.stamps = 0
                newCard.maxStamps = 8
                newCard.totalPoints = 0
                newCard.user = user
                card = newCard
            }

            card.stamps += 1
            if card.stamps >= card.maxStamps {
                card.stamps = 0
                card.totalPoints += 500
            }

            try context.save()
        }
    }

    // MARK: - Add Points

    /// Adds points to the user's loyalty card. Creates the card if missing.
    func addPoints(_ points: Int32, for userID: UUID) async throws {
        try await stack.performBackgroundTask { context in
            let user = try self.fetchUser(id: userID, in: context)
            let card: CDLoyaltyCard
            if let existing = user.loyaltyCard {
                card = existing
            } else {
                let newCard = CDLoyaltyCard(context: context)
                newCard.id = UUID()
                newCard.stamps = 0
                newCard.maxStamps = 8
                newCard.totalPoints = 0
                newCard.user = user
                card = newCard
            }

            card.totalPoints += points
            try context.save()
        }
    }

    // MARK: - Redeem Reward

    /// Deducts points and records a CDRewardHistory entry.
    /// Throws `LoyaltyServiceError.insufficientPoints` if the user can't afford the reward.
    func redeemReward(name: String, cost: Int32, for userID: UUID) async throws {
        try await stack.performBackgroundTask { context in
            let user = try self.fetchUser(id: userID, in: context)
            guard let card = user.loyaltyCard else {
                throw LoyaltyServiceError.insufficientPoints
            }
            guard card.totalPoints >= cost else {
                throw LoyaltyServiceError.insufficientPoints
            }

            card.totalPoints -= cost

            let history = CDRewardHistory(context: context)
            history.id = UUID()
            history.date = Date()
            history.points = cost
            history.productName = name
            history.user = user

            try context.save()
        }
    }

    // MARK: - Fetch History

    /// Returns reward history entries for a user, sorted newest first.
    func fetchHistory(for userID: UUID) async throws -> [CDRewardHistory] {
        let objectIDs: [NSManagedObjectID] = try await stack.performBackgroundTask { context in
            let request = CDRewardHistory.fetchRequest()
            request.predicate = NSPredicate(format: "user.id == %@", userID as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let items = try context.fetch(request)
            return items.map { $0.objectID }
        }

        return await MainActor.run {
            objectIDs.compactMap { id in
                stack.viewContext.object(with: id) as? CDRewardHistory
            }
        }
    }

    // MARK: - Private

    private func fetchUser(id: UUID, in context: NSManagedObjectContext) throws -> CDUser {
        let request = CDUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        guard let user = try context.fetch(request).first else {
            throw LoyaltyServiceError.userNotFound
        }
        return user
    }
}
