import UIKit

extension UIFont {
    static func poppins(_ weight: UIFont.Weight, size: CGFloat) -> UIFont {
        let name: String
        switch weight {
        case .bold:   name = "Poppins-Bold"
        case .medium: name = "Poppins-Medium"
        default:      name = "Poppins-Regular"
        }
        return UIFont(name: name, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }

    static func dmSans(_ weight: UIFont.Weight, size: CGFloat) -> UIFont {
        let name: String
        switch weight {
        case .medium: name = "DMSans-Medium"
        default:      name = "DMSans-Regular"
        }
        return UIFont(name: name, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
}
