import Combine
import Foundation

final class SignUpViewModel: BaseViewModel {
    @Published var email = ""
    @Published var addressOrPhone = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?

    private let authService: AuthService

    init(authService: AuthService = .shared) {
        self.authService = authService
    }

    func signUp() {
        let email = self.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.password
        let address = addressOrPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty, !password.isEmpty else {
            error = "Please enter an email and password."
            return
        }

        Task { @MainActor in
            isLoading = true
            defer { isLoading = false }
            do {
                try await authService.register(
                    email: email,
                    password: password,
                    address: address.isEmpty ? nil : address
                )
                (coordinator as? AuthCoordinator)?.showVerification(email: email)
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    func goToSignIn() {
        (coordinator as? AuthCoordinator)?.popToSignIn()
    }
}
