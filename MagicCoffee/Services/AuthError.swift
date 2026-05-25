import Foundation

enum AuthError: LocalizedError, Equatable {
    case emailAlreadyInUse
    case invalidCredentials
    case invalidOTP

    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .invalidCredentials:
            return "Invalid email or password."
        case .invalidOTP:
            return "The code you entered is incorrect."
        }
    }
}
