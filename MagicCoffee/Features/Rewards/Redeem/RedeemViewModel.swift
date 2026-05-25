import Combine
import Foundation

// MARK: - RedeemProduct

struct RedeemProduct {
    let name: String
    let cost: Int32
    let symbolName: String
}

// MARK: - RedeemViewModel

final class RedeemViewModel: BaseViewModel {
    // MARK: - Data

    let products: [RedeemProduct] = [
        RedeemProduct(name: "Latte",      cost: 150, symbolName: "cup.and.saucer.fill"),
        RedeemProduct(name: "Flat White", cost: 200, symbolName: "mug.fill"),
        RedeemProduct(name: "Cappuccino", cost: 250, symbolName: "cup.and.heat.waves.fill"),
    ]

    // MARK: - Published State

    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var didRedeem: Bool = false

    // MARK: - Dependencies

    private let loyaltyService: LoyaltyService
    let userID: UUID

    // MARK: - Init

    init(loyaltyService: LoyaltyService = .shared, userID: UUID) {
        self.loyaltyService = loyaltyService
        self.userID = userID
    }

    // MARK: - Actions

    func redeem(product: RedeemProduct) {
        Task { @MainActor in
            do {
                try await loyaltyService.redeemReward(name: product.name, cost: product.cost, for: userID)
                didRedeem = true
            } catch LoyaltyServiceError.insufficientPoints {
                errorMessage = "Not enough points to redeem \(product.name)."
            } catch {
                errorMessage = "Something went wrong. Please try again."
            }
        }
    }
}
