import Combine
import Foundation

final class HistoryOrdersViewModel: BaseViewModel {

    @Published private(set) var orders: [CDOrder] = []

    private let orderService: OrderService
    private let authService: AuthService

    init(orderService: OrderService = .shared, authService: AuthService = .shared) {
        self.orderService = orderService
        self.authService = authService
    }

    func loadOrders() {
        guard let userID = authService.currentUser()?.id else { return }
        Task { @MainActor in
            do {
                orders = try await orderService.fetchHistoryOrders(for: userID)
            } catch {
                orders = []
            }
        }
    }
}
