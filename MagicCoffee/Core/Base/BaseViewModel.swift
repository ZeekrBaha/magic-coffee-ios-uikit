import Combine

class BaseViewModel {
    var cancellables = Set<AnyCancellable>()
    weak var coordinator: (any Coordinator)?
}
