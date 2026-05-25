import UIKit

/// Small factory helpers shared by the auth screens to keep view controllers DRY.
enum AuthUI {

    static func titleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .poppins(.bold, size: 26)
        label.textColor = .mcPrimary
        return label
    }

    static func subtitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .poppins(.regular, size: 14)
        label.textColor = UIColor(hex: "#9B9B9B")
        return label
    }

    static func errorLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppins(.regular, size: 13)
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.isHidden = true
        label.accessibilityIdentifier = "auth_error_label"
        return label
    }

    /// A button with a regular-weight prefix and an accent-colored, bold action word.
    static func linkButton(prefix: String, action: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let attributed = NSMutableAttributedString(
            string: prefix,
            attributes: [
                .font: UIFont.poppins(.regular, size: 14),
                .foregroundColor: UIColor(hex: "#9B9B9B")
            ]
        )
        attributed.append(NSAttributedString(
            string: action,
            attributes: [
                .font: UIFont.poppins(.bold, size: 14),
                .foregroundColor: UIColor.mcAccent
            ]
        ))
        button.setAttributedTitle(attributed, for: .normal)
        return button
    }

    /// A top-left back arrow bar button look-alike implemented as a plain button.
    static func backButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .mcPrimary
        button.accessibilityIdentifier = "auth_back_button"
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        return button
    }
}
