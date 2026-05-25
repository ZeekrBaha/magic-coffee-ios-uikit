import Combine
import Foundation

final class ProfileViewModel: BaseViewModel {
    // MARK: - Published fields

    @Published var name: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var address: String = ""

    // MARK: - Dependencies

    private let authService: AuthService

    // MARK: - Init

    init(authService: AuthService = .shared) {
        self.authService = authService
    }

    // MARK: - Actions

    /// Populates published fields from the active CDUser.
    func loadUser() {
        guard let user = authService.currentUser() else { return }
        name    = user.name    ?? ""
        phone   = user.phone   ?? ""
        email   = user.email   ?? ""
        address = user.address ?? ""
    }

    /// Persists the current field values back to the active CDUser.
    /// No-op if there is no active user (graceful).
    func save() {
        authService.updateCurrentUser(
            name: name,
            phone: phone.isEmpty ? nil : phone,
            email: email,
            address: address.isEmpty ? nil : address
        )
    }
}
