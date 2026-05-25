import Combine
import Foundation

final class StoreListViewModel: BaseViewModel {
    @Published var stores: [CDStore] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let storeService: StoreService

    init(storeService: StoreService = .shared) {
        self.storeService = storeService
    }

    func loadStores() {
        Task { @MainActor in
            isLoading = true
            defer { isLoading = false }
            do {
                stores = try await storeService.fetchAll()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// Called when the user taps a store row.
    func selectStore(_ store: CDStore) {
        (coordinator as? StoreSelectionCoordinator)?.showMap(stores: stores, selectedStore: store)
    }
}
