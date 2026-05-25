import Combine
import Foundation

final class PaymentViewModel {
    // MARK: - Published state

    enum PaymentOption {
        case online
        case card
    }

    @Published private(set) var selectedOption: PaymentOption = .online
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?

    // MARK: - Dependencies

    private let state: AssemblageState
    private let orderService: OrderService

    // MARK: - Output

    /// Called when the order has been successfully placed. Carries the CDOrder.
    var onOrderPlaced: ((CDOrder) -> Void)?

    // MARK: - Init

    init(state: AssemblageState, orderService: OrderService = .shared) {
        self.state = state
        self.orderService = orderService
    }

    // MARK: - Input

    func select(option: PaymentOption) {
        selectedOption = option
    }

    /// Places the order via OrderService.
    /// Requires `state.selectedProduct` and `state.selectedStoreID` to be set.
    func pay() {
        guard let product = state.selectedProduct else { return }
        guard let storeID = state.selectedStoreID else { return }

        let methodString = selectedOption == .online ? "online" : "card"
        isLoading = true
        error = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                let order = try await self.orderService.placeOrder(
                    product: product,
                    state: self.state,
                    storeID: storeID,
                    paymentMethod: methodString
                )
                await MainActor.run {
                    self.isLoading = false
                    self.onOrderPlaced?(order)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.error = error
                }
            }
        }
    }

    // MARK: - Display

    var storeAddressText: String {
        // AssemblageState carries the store name from the store selection step.
        // For now surface what's available; coordinator can populate selectedStoreName.
        return state.selectedStoreName ?? "Selected Store"
    }
}
