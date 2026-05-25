import Combine
import UIKit

final class ForgotPasswordViewController: UIViewController {

    private let viewModel: ForgotPasswordViewModel
    var cancellables = Set<AnyCancellable>()

    private let backButton = AuthUI.backButton()
    private let titleLabel: UILabel = {
        let label = AuthUI.titleLabel("Forgot Password?")
        label.font = .poppins(.bold, size: 24)
        label.numberOfLines = 0
        return label
    }()
    private let subtitleLabel = AuthUI.subtitleLabel("Enter your email address")

    private let emailField = MCTextField(icon: "envelope", placeholder: "Email address", keyboardType: .emailAddress)
    private let errorLabel = AuthUI.errorLabel()
    private let nextButton = MCButton()

    init(viewModel: ForgotPasswordViewModel) {
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
        nextButton.accessibilityIdentifier = "forgot_next_button"
        emailField.textField.accessibilityIdentifier = "forgot_email_field"
        setupLayout()
        setupActions()
        bind()
    }

    private func setupLayout() {
        [backButton, titleLabel, subtitleLabel, emailField, errorLabel, nextButton]
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

            emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            emailField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            errorLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            nextButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        emailField.textField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
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

    @objc private func emailChanged() { viewModel.email = emailField.text }
    @objc private func didTapBack() { viewModel.goBack() }
    @objc private func didTapNext() { view.endEditing(true); viewModel.submit() }
}
