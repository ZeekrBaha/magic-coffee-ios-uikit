import Foundation

final class BaristaSelectionViewModel {
    private(set) var baristas: [CDBarista] = []
    let state: AssemblageState
    private let service: BaristaService

    var onBaristasLoaded: (() -> Void)?
    var onError: ((Error) -> Void)?

    init(state: AssemblageState, service: BaristaService = .shared) {
        self.state = state
        self.service = service
    }

    func loadBaristas() {
        Task { @MainActor in
            do {
                baristas = try await service.fetchAll()
                onBaristasLoaded?()
            } catch {
                onError?(error)
            }
        }
    }

    func select(baristaAt index: Int) {
        guard index < baristas.count else { return }
        state.selectedBaristaID = baristas[index].id
    }
}
