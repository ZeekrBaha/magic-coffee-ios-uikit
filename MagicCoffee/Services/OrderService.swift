import CoreData
import Foundation

/// Persists orders to Core Data and manages loyalty stamp increments.
/// Injectable via `init(stack:authService:)` for testing.
final class OrderService {
    static let shared = OrderService()

    private let stack: CoreDataStack
    private let authService: AuthService

    init(stack: CoreDataStack = .shared, authService: AuthService = .shared) {
        self.stack = stack
        self.authService = authService
    }

    // MARK: - Place Order

    /// Creates a CDOrder + CDOrderItem, increments loyalty stamps, and returns the saved order.
    /// - Parameters:
    ///   - product: The product being ordered.
    ///   - state: The customization state from the assemblage flow.
    ///   - storeID: UUID of the selected store.
    ///   - paymentMethod: A string describing the payment method (e.g. "online", "card").
    /// - Returns: The newly created CDOrder on the view context.
    @discardableResult
    func placeOrder(
        product: CDProduct,
        state: AssemblageState,
        storeID: UUID,
        paymentMethod: String
    ) async throws -> CDOrder {

        // Capture object IDs before entering the background task so we
        // don't cross context boundaries with managed objects directly.
        let productObjectID = product.objectID

        // Capture current active user's objectID on the main actor's context.
        guard let currentUser = authService.currentUser() else {
            throw OrderServiceError.noActiveUser
        }
        let userObjectID = currentUser.objectID

        // Perform all Core Data writes on a background context.
        let orderObjectID: NSManagedObjectID = try await stack.performBackgroundTask { context in
            // Resolve objects in the background context.
            guard let bgProduct = try? context.existingObject(with: productObjectID) as? CDProduct else {
                throw OrderServiceError.productNotFound
            }
            guard let bgUser = try? context.existingObject(with: userObjectID) as? CDUser else {
                throw OrderServiceError.userNotFound
            }

            // Resolve store.
            let storeRequest = CDStore.fetchRequest()
            storeRequest.predicate = NSPredicate(format: "id == %@", storeID as CVarArg)
            storeRequest.fetchLimit = 1
            guard let bgStore = try context.fetch(storeRequest).first else {
                throw OrderServiceError.storeNotFound
            }

            // Resolve barista if one was selected.
            var bgBarista: CDBarista?
            if let baristaID = state.selectedBaristaID {
                let baristaRequest = CDBarista.fetchRequest()
                baristaRequest.predicate = NSPredicate(format: "id == %@", baristaID as CVarArg)
                baristaRequest.fetchLimit = 1
                bgBarista = try context.fetch(baristaRequest).first
            }

            // Compute price.
            let price = bgProduct.price ?? NSDecimalNumber.zero

            // Create CDOrder.
            let order = CDOrder(context: context)
            order.id = UUID()
            order.status = "ongoing"
            order.createdAt = Date()
            order.isOnsite = state.isOnsite
            order.totalAmount = price
            order.pickupCode = String(order.id!.uuidString.prefix(6).uppercased())
            order.user = bgUser
            order.store = bgStore
            order.barista = bgBarista

            // Create CDOrderItem.
            let item = CDOrderItem(context: context)
            item.id = UUID()
            item.quantity = 1
            item.price = price
            item.milkType = state.milkType == "None" ? nil : state.milkType
            item.syrupType = state.syrupType == "None" ? nil : state.syrupType
            item.additives = state.selectedAdditives.isEmpty ? nil : state.selectedAdditives.joined(separator: ",")
            item.product = bgProduct
            item.order = order

            // Increment or create loyalty card.
            if let loyaltyCard = bgUser.loyaltyCard {
                loyaltyCard.stamps += 1
            } else {
                let card = CDLoyaltyCard(context: context)
                card.id = UUID()
                card.stamps = 1
                card.maxStamps = 8
                card.totalPoints = 0
                card.user = bgUser
            }

            try context.save()
            return order.objectID
        }

        // Return the order on the view context.
        return try await MainActor.run {
            guard let order = try? stack.viewContext.existingObject(with: orderObjectID) as? CDOrder else {
                throw OrderServiceError.saveFailed
            }
            return order
        }
    }

    // MARK: - Fetch Orders

    /// Returns all orders with status "ongoing" for the given user, sorted newest first.
    func fetchOngoingOrders(for userID: UUID) async throws -> [CDOrder] {
        try await fetchOrders(status: "ongoing", userID: userID)
    }

    /// Returns all orders with status "completed" for the given user, sorted newest first.
    func fetchHistoryOrders(for userID: UUID) async throws -> [CDOrder] {
        try await fetchOrders(status: "completed", userID: userID)
    }

    private func fetchOrders(status: String, userID: UUID) async throws -> [CDOrder] {
        let objectIDs: [NSManagedObjectID] = try await stack.performBackgroundTask { context in
            let request = CDOrder.fetchRequest()
            request.predicate = NSPredicate(
                format: "status == %@ AND user.id == %@",
                status, userID as CVarArg
            )
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            let orders = try context.fetch(request)
            return orders.map { $0.objectID }
        }

        return try await MainActor.run {
            objectIDs.compactMap { id in
                try? stack.viewContext.existingObject(with: id) as? CDOrder
            }
        }
    }
}

// MARK: - OrderServiceError

enum OrderServiceError: Error, Equatable {
    case noActiveUser
    case productNotFound
    case storeNotFound
    case userNotFound
    case saveFailed
}
