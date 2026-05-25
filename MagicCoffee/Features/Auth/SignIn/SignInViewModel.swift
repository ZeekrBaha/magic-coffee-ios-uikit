import Combine
import Foundation

final class SignInViewModel: BaseViewModel {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?

    private let authService: AuthService

    init(authService: AuthService = .shared) {
        self.authService = authService
    }

    func signIn() {
        let email = self.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.password
        guard !email.isEmpty, !password.isEmpty else {
            error = "Please enter your email and password."
            return
        }

        Task { @MainActor in
            isLoading = true
            defer { isLoading = false }
            do {
                _ = try await authService.login(email: email, password: password)
                (coordinator as? AuthCoordinator)?.showVerification(email: email)
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    func goToSignUp() {
        (coordinator as? AuthCoordinator)?.showSignUp()
    }

    func goToForgotPassword() {
        (coordinator as? AuthCoordinator)?.showForgotPassword()
    }
}
