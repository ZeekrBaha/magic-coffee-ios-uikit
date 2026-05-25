import UIKit

final class SplashViewController: UIViewController {

    private let viewModel: SplashViewModel

    private let logoView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .mcPrimary
        // Prefer a real asset if it exists, otherwise fall back to an SF Symbol.
        if let asset = UIImage(named: "magic_coffee_logo") {
            iv.image = asset
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
            iv.image = UIImage(systemName: "leaf.fill", withConfiguration: config)
        }
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Feel yourself\nlike a barista!"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .poppins(.bold, size: 24)
        label.textColor = .mcPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Magic coffee on order..."
        label.textAlignment = .center
        label.font = .poppins(.regular, size: 14)
        label.textColor = UIColor(hex: "#9B9B9B")
        return label
    }()

    private let pageDots: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        for i in 0..<3 {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.layer.cornerRadius = 4
            dot.backgroundColor = i == 0 ? .mcPrimary : .mcTextSecondary
            dot.widthAnchor.constraint(equalToConstant: 8).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 8).isActive = true
            stack.addArrangedSubview(dot)
        }
        return stack
    }()

    private let nextButton = MCButton()

    init(viewModel: SplashViewModel) {
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
        setupLayout()
        nextButton.accessibilityIdentifier = "splash_next_button"
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }

    private func setupLayout() {
        view.addSubview(logoView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(pageDots)
        view.addSubview(nextButton)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.topAnchor.constraint(equalTo: safe.topAnchor, constant: 100),
            logoView.widthAnchor.constraint(equalToConstant: 120),
            logoView.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 48),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),

            pageDots.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageDots.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -32),

            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -48)
        ])
    }

    @objc private func didTapNext() {
        viewModel.advance()
    }
}
