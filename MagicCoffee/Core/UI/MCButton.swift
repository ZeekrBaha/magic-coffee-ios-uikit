import UIKit

/// The circular primary arrow button used across the auth screens.
/// 56x56 circle, mcPrimary background, white chevron.right.
final class MCButton: UIButton {

    init() {
        super.init(frame: .zero)
        configureAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureAppearance()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 56, height: 56)
    }

    private func configureAppearance() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .mcPrimary
        layer.cornerRadius = 28
        tintColor = .white

        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let image = UIImage(systemName: "chevron.right", withConfiguration: config)
        setImage(image, for: .normal)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 56),
            heightAnchor.constraint(equalToConstant: 56)
        ])
    }
}
