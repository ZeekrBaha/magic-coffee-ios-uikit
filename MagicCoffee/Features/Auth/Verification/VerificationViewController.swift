import Combine
import UIKit

final class VerificationViewController: UIViewController, UITextFieldDelegate {

    private let viewModel: VerificationViewModel
    var cancellables = Set<AnyCancellable>()

    private let backButton = AuthUI.backButton()
    private let titleLabel: UILabel = {
        let label = AuthUI.titleLabel("Verification")
        label.font = .poppins(.bold, size: 24)
        return label
    }()
    private let subtitleLabel = AuthUI.subtitleLabel("Enter the OTP code we sent you")

    private var digitFields: [UITextField] = []
    private let errorLabel = AuthUI.errorLabel()
    private let nextButton = MCButton()

    init(viewModel: VerificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.setHidesBackButton(true, animated: false)
        nextButton.accessibilityIdentifier = "otp_next_button"
        setupLayout()
        setupActions()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        digitFields.first?.becomeFirstResponder()
    }

    private func makeDigitField(index: Int) -> UITextField {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.textAlignment = .center
        field.font = .poppins(.bold, size: 24)
        field.textColor = .mcTextPrimary
        field.keyboardType = .numberPad
        field.backgroundColor = .mcCardBg
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor(hex: "#E5E8EF").cgColor
        field.delegate = self
        field.tag = index
        field.accessibilityIdentifier = "otp_digit_\(index)"
        field.addTarget(self, action: #selector(digitChanged(_:)), for: .editingChanged)
        NSLayoutConstraint.activate([
            field.widthAnchor.constraint(equalToConstant: 50),
            field.heightAnchor.constraint(equalToConstant: 60)
        ])
        return field
    }

    private func setupLayout() {
        digitFields = (0..<4).map { makeDigitField(index: $0) }
        let otpStack = UIStackView(arrangedSubviews: digitFields)
        otpStack.translatesAutoresizingMaskIntoConstraints = false
        otpStack.axis = .horizontal
        otpStack.spacing = 16
        otpStack.distribution = .fillEqually

        [backButton, titleLabel, subtitleLabel, otpStack, errorLabel, nextButton]
            .forEach { view.addSubview($0) }

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            otpStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            otpStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            errorLabel.topAnchor.constraint(equalTo: otpStack.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            nextButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }

    private func bind() {
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.errorLabel.text = message
                self?.errorLabel.isHidden = (message == nil)
            }
            .store(in: &cancellables)
    }

    private func currentCode() -> String {
        digitFields.map { $0.text ?? "" }.joined()
    }

    @objc private func digitChanged(_ field: UITextField) {
        // Keep only the last typed character per box.
        if let text = field.text, text.count > 1 {
            field.text = String(text.suffix(1))
        }
        viewModel.code = currentCode()

        if let text = field.text, !text.isEmpty {
            let next = field.tag + 1
            if next < digitFields.count {
                digitFields[next].becomeFirstResponder()
            } else {
                field.resignFirstResponder()
            }
        }
    }

    // Handle backspace on an empty box: move focus to the previous box.
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string.isEmpty, (textField.text ?? "").isEmpty, textField.tag > 0 {
            let previous = digitFields[textField.tag - 1]
            previous.text = ""
            previous.becomeFirstResponder()
            viewModel.code = currentCode()
        }
        return true
    }

    @objc private func didTapBack() { viewModel.goBack() }
    @objc private func didTapNext() {
        view.endEditing(true)
        viewModel.code = currentCode()
        viewModel.verify()
    }
}
