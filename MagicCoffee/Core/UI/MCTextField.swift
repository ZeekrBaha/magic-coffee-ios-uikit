import UIKit

/// A reusable rounded text field with a leading SF Symbol icon and an optional
/// trailing eye toggle for secure (password) entry.
final class MCTextField: UIView {

    let textField = UITextField()

    private let iconView = UIImageView()
    private let eyeButton = UIButton(type: .system)
    private let isSecure: Bool

    /// - Parameters:
    ///   - icon: SF Symbol name shown on the leading edge.
    ///   - placeholder: Placeholder text.
    ///   - isSecure: When true, text is masked and a trailing eye toggle is shown.
    ///   - keyboardType: Keyboard type for the field.
    init(icon: String,
         placeholder: String,
         isSecure: Bool = false,
         keyboardType: UIKeyboardType = .default) {
        self.isSecure = isSecure
        super.init(frame: .zero)
        configure(icon: icon, placeholder: placeholder, keyboardType: keyboardType)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 48)
    }

    var text: String { textField.text ?? "" }

    private func configure(icon: String, placeholder: String, keyboardType: UIKeyboardType) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .mcCardBg
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor(hex: "#E5E8EF").cgColor

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .mcPrimary
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.font = .poppins(.regular, size: 14)
        textField.textColor = .mcTextPrimary
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = isSecure
        addSubview(textField)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48),

            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            textField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        if isSecure {
            eyeButton.translatesAutoresizingMaskIntoConstraints = false
            eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            eyeButton.tintColor = .mcTextSecondary
            eyeButton.addTarget(self, action: #selector(toggleSecure), for: .touchUpInside)
            addSubview(eyeButton)

            NSLayoutConstraint.activate([
                eyeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                eyeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                eyeButton.widthAnchor.constraint(equalToConstant: 24),
                eyeButton.heightAnchor.constraint(equalToConstant: 24),
                textField.trailingAnchor.constraint(equalTo: eyeButton.leadingAnchor, constant: -8)
            ])
        } else {
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        }
    }

    @objc private func toggleSecure() {
        textField.isSecureTextEntry.toggle()
        let symbol = textField.isSecureTextEntry ? "eye.slash" : "eye"
        eyeButton.setImage(UIImage(systemName: symbol), for: .normal)
    }
}
