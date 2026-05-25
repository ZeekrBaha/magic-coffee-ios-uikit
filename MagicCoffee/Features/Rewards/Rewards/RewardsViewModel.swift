import Combine
import Foundation

final class RewardsViewModel: BaseViewModel {
    // MARK: - Published State

    @Published private(set) var stamps: Int16 = 0
    @Published private(set) var maxStamps: Int16 = 8
    @Published private(set) var totalPoints: Int32 = 0
    @Published private(set) var history: [CDRewardHistory] = []
    @Published private(set) var isLoading: Bool = false

    // MARK: - Dependencies

    private let loyaltyService: LoyaltyService
    private let authService: AuthService

    // MARK: - Init

    init(loyaltyService: LoyaltyService = .shared, authService: AuthService = .shared) {
        self.loyaltyService = loyaltyService
        self.authService = authService
    }

    // MARK: - Current User

    var currentUserID: UUID? {
        authService.currentUser()?.id
    }

    // MARK: - Actions

    func loadData() {
        guard let userID = currentUserID else { return }
        isLoading = true
        Task { @MainActor in
            defer { isLoading = false }
            do {
                if let card = try await loyaltyService.fetchLoyaltyCard(for: userID) {
                    stamps = card.stamps
                    maxStamps = card.maxStamps
                    totalPoints = card.totalPoints
                } else {
                    stamps = 0
                    maxStamps = 8
                    totalPoints = 0
                }
                history = try await loyaltyService.fetchHistory(for: userID)
            } catch {
                // Silently fail — no card yet is a valid state.
            }
        }
    }

    func redeemTapped() {
        guard let userID = currentUserID else { return }
        (coordinator as? RewardsCoordinator)?.showRedeem(userID: userID)
    }
}
