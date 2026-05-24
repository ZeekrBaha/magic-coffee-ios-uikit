import UIKit

extension UIColor {
    static let mcPrimary       = UIColor(hex: "#314B59")
    static let mcAccent        = UIColor(hex: "#4ECDC4")
    static let mcCardBg        = UIColor(hex: "#F7F8FB")
    static let mcTextPrimary   = UIColor(hex: "#001833")
    static let mcTextSecondary = UIColor(hex: "#D8D8D8")
    static let mcStar          = UIColor(hex: "#FF9500")
    static let mcSurface       = UIColor.white

    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64(0)
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
