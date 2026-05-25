import Combine
import Foundation

final class MapViewModel: BaseViewModel {
    @Published var stores: [CDStore]
    @Published var selectedStore: CDStore

    init(stores: [CDStore], initialSelection: CDStore) {
        self.stores = stores
        self.selectedStore = initialSelection
    }

    /// Called when the user taps a map pin.
    func selectStore(_ store: CDStore) {
        selectedStore = store
    }

    /// Called when the user taps the "Select Store" confirm button.
    func confirmSelection() {
        guard let id = selectedStore.id else { return }
        (coordinator as? StoreSelectionCoordinator)?.confirmStoreSelection(storeID: id)
    }
}
