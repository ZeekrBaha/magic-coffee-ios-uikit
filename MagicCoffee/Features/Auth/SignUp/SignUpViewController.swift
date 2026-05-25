import Combine
import UIKit

final class SignUpViewController: UIViewController {

    private let viewModel: SignUpViewModel
    var cancellables = Set<AnyCancellable>()

    private let titleLabel = AuthUI.titleLabel("Sign up")
    private let subtitleLabel = AuthUI.subtitleLabel("Create an account here")

    private let emailField = MCTextField(icon: "envelope", placeholder: "Email address", keyboardType: .emailAddress)
    private let addressField = MCTextField(icon: "person", placeholder: "Address or phone")
    private let passwordField = MCTextField(icon: "lock", placeholder: "Password", isSecure: true)

    private let nextButton = MCButton()
    private let signInLink = AuthUI.linkButton(prefix: "Already a member? ", action: "Sign in")
    private let errorLabel = AuthUI.errorLabel()
    private let spinner = UIActivityIndicatorView(style: .medium)

    init(viewModel: SignUpViewModel) {
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
        setupIdentifiers()
        setupLayout()
        setupActions()
        bind()
    }

    private func setupIdentifiers() {
        emailField.textField.accessibilityIdentifier = "signup_email_field"
        addressField.textField.accessibilityIdentifier = "signup_address_field"
        passwordField.textField.accessibilityIdentifier = "signup_password_field"
        nextButton.accessibilityIdentifier = "signup_next_button"
        signInLink.accessibilityIdentifier = "signup_signin_link"
    }

    private func setupLayout() {
        [titleLabel, subtitleLabel, emailField, addressField, passwordField,
         errorLabel, nextButton, signInLink, spinner].forEach { view.addSubview($0) }
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            emailField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            addressField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            addressField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            addressField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            passwordField.topAnchor.constraint(equalTo: addressField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            errorLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            nextButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            spinner.centerXAnchor.constraint(equalTo: nextButton.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor),

            signInLink.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInLink.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -32)
        ])
    }

    private func setupActions() {
        emailField.textField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        addressField.textField.addTarget(self, action: #selector(addressChanged), for: .editingChanged)
        passwordField.textField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        signInLink.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }

    private func bind() {
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.errorLabel.text = message
                self?.errorLabel.isHidden = (message == nil)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                guard let self else { return }
                if loading { self.spinner.startAnimating() } else { self.spinner.stopAnimating() }
                self.nextButton.isEnabled = !loading
                self.nextButton.imageView?.isHidden = loading
            }
            .store(in: &cancellables)
    }

    @objc private func emailChanged() { viewModel.email = emailField.text }
    @objc private func addressChanged() { viewModel.addressOrPhone = addressField.text }
    @objc private func passwordChanged() { viewModel.password = passwordField.text }
    @objc private func didTapNext() { view.endEditing(true); viewModel.signUp() }
    @objc private func didTapSignIn() { viewModel.goToSignIn() }
}
