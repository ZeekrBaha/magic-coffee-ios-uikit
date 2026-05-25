import Combine
import UIKit

/// Post-order review modal (screen 26): a centered card over a dimmed backdrop with a
/// "Order completed. Rate the service." prompt, five tappable stars, and two dismiss
/// actions. Present with `.overFullScreen` so the underlying screen stays visible.
final class ReviewViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: ReviewViewModel
    private var cancellables = Set<AnyCancellable>()

    /// Called whenever the modal should be dismissed (after a star tap, "Remind me
    /// later", or "No thanks"). The coordinator owns the actual dismissal.
    var onFinish: (() -> Void)?

    // MARK: - UI

    private let backdropView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .mcSurface
        v.layer.cornerRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Order completed."
        l.font = .poppins(.bold, size: 20)
        l.textColor = .mcPrimary
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.accessibilityIdentifier = "review_title"
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Rate the service."
        l.font = .poppins(.regular, size: 15)
        l.textColor = .mcTextPrimary
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let starsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    /// Five star buttons, tag 1...5.
    private lazy var starButtons: [UIButton] = (1...5).map { index in
        let b = UIButton(type: .system)
        b.tag = index
        b.tintColor = .mcStar
        b.setImage(Self.starImage(filled: false), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.accessibilityIdentifier = "review_star_\(index)"
        b.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
        return b
    }

    private let remindButton: UIButton = {
        var config = UIButton.Configuration.plain()
        var attr = AttributeContainer()
        attr.font = UIFont.poppins(.medium, size: 15)
        attr.foregroundColor = UIColor.mcAccent
        config.attributedTitle = AttributedString("Remind me later", attributes: attr)
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.accessibilityIdentifier = "review_remind_button"
        return b
    }()

    private let noThanksButton: UIButton = {
        var config = UIButton.Configuration.plain()
        var attr = AttributeContainer()
        attr.font = UIFont.poppins(.medium, size: 15)
        attr.foregroundColor = UIColor.mcTextPrimary.withAlphaComponent(0.5)
        config.attributedTitle = AttributedString("No thanks", attributes: attr)
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.accessibilityIdentifier = "review_nothanks_button"
        return b
    }()

    // MARK: - Init

    init(viewModel: ReviewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(backdropView)
        view.addSubview(cardView)

        starButtons.forEach { starsStackView.addArrangedSubview($0) }

        [titleLabel, subtitleLabel, starsStackView, remindButton, noThanksButton]
            .forEach { cardView.addSubview($0) }

        remindButton.addTarget(self, action: #selector(remindTapped), for: .touchUpInside)
        noThanksButton.addTarget(self, action: #selector(noThanksTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(equalTo: view.topAnchor),
            backdropView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdropView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            starsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            starsStackView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            starsStackView.heightAnchor.constraint(equalToConstant: 40),

            remindButton.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 28),
            remindButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            noThanksButton.topAnchor.constraint(equalTo: remindButton.bottomAnchor, constant: 4),
            noThanksButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            noThanksButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
        ])

        // Fixed star size so the row stays compact and centered.
        for button in starButtons {
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
    }

    // MARK: - Bind

    private func bindViewModel() {
        viewModel.$rating
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rating in
                self?.updateStars(filledUpTo: rating)
            }
            .store(in: &cancellables)
    }

    private func updateStars(filledUpTo rating: Int) {
        for button in starButtons {
            let filled = button.tag <= rating
            button.setImage(Self.starImage(filled: filled), for: .normal)
        }
    }

    private static func starImage(filled: Bool) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
        return UIImage(systemName: filled ? "star.fill" : "star", withConfiguration: config)
    }

    // MARK: - Actions

    @objc private func starTapped(_ sender: UIButton) {
        viewModel.selectRating(sender.tag)
        // Let the user briefly see their selection, then dismiss.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.onFinish?()
        }
    }

    @objc private func remindTapped() {
        onFinish?()
    }

    @objc private func noThanksTapped() {
        onFinish?()
    }
}
