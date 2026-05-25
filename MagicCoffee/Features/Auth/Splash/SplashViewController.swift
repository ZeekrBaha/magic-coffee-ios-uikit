import UIKit

final class SplashViewController: UIViewController {

    private let viewModel: SplashViewModel

    /// Dark teal header card holding the brand mark (matches the Figma design).
    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .mcPrimary
        v.layer.cornerRadius = 24
        return v
    }()

    private let logoView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        // The Magic Coffee tree mark (white, with the tree as a transparent cutout
        // so the dark card shows through). Falls back to an SF Symbol if missing.
        if let asset = UIImage(named: "mc_logo") {
            iv.image = asset
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
            iv.image = UIImage(systemName: "leaf.fill", withConfiguration: config)
            iv.tintColor = .white
        }
        return iv
    }()

    private let wordmarkLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Magic Coffee"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "BradleyHandITCTT-Bold", size: 38)
            ?? UIFont(name: "Bradley Hand", size: 38)
            ?? .systemFont(ofSize: 34, weight: .bold)
        return label
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
            // The active (first) dot is an elongated pill.
            dot.widthAnchor.constraint(equalToConstant: i == 0 ? 24 : 8).isActive = true
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
        view.addSubview(cardView)
        cardView.addSubview(logoView)
        cardView.addSubview(wordmarkLabel)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(pageDots)
        view.addSubview(nextButton)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.42),

            logoView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor, constant: -24),
            logoView.widthAnchor.constraint(equalToConstant: 150),
            logoView.heightAnchor.constraint(equalToConstant: 150),

            wordmarkLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            wordmarkLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 4),
            wordmarkLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            wordmarkLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 48),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),

            pageDots.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageDots.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -32),

            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -48),
        ])
    }

    @objc private func didTapNext() {
        viewModel.advance()
    }
}
