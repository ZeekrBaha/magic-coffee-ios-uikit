import Foundation

final class CountrySelectionViewModel {
    let countries: [String] = [
        "Brazil", "Colombia", "Jamaica", "Minas", "Rio",
        "Tanzania", "Hawaii", "Indonesia", "Ethiopia"
    ]
    let state: AssemblageState

    init(state: AssemblageState) {
        self.state = state
    }

    func select(_ country: String) {
        state.selectedCountry = country
    }
}
