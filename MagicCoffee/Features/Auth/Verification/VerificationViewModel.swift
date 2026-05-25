import Combine
import Foundation

final class VerificationViewModel: BaseViewModel {
    static let validOTP = "1234"

    let email: String
    @Published var code = ""
    @Published var error: String?

    init(email: String) {
        self.email = email
    }

    func verify() {
        guard code == Self.validOTP else {
            error = AuthError.invalidOTP.localizedDescription
            return
        }
        error = nil
        (coordinator as? AuthCoordinator)?.finishAuth()
    }

    func goBack() {
        (coordinator as? AuthCoordinator)?.navigationController.popViewController(animated: true)
    }
}
