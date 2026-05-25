import Combine
import Foundation

final class ForgotPasswordViewModel: BaseViewModel {
    @Published var email = ""
    @Published var error: String?
    @Published var didSubmit = false

    func submit() {
        let email = self.email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else {
            error = "Please enter your email address."
            return
        }
        // No real reset backend; acknowledge and return to sign-in.
        didSubmit = true
        (coordinator as? AuthCoordinator)?.popToSignIn()
    }

    func goBack() {
        (coordinator as? AuthCoordinator)?.navigationController.popViewController(animated: true)
    }
}
