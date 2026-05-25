import Foundation

final class SplashViewModel: BaseViewModel {
    func advance() {
        (coordinator as? AuthCoordinator)?.showSignIn()
    }
}
