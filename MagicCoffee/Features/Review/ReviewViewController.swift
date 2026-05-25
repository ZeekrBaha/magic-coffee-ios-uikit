import Combine
import UIKit

/// Post-order review modal (screen 26): an iOS-style bottom action sheet over a dimmed
/// backdrop, matching the Figma design — title + subtitle, five tappable stars, and two
/// hairline-separated actions ("Remind me later", "No, thanks"). Present with
/// `.overFullScreen` so the underlying screen stays visible.
final class ReviewViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: ReviewViewModel
    private var cancellables = Set<AnyCancellable>()

    /// Called whenever the modal should be dismissed (after a star tap, "Remind me
    /// later", or "No, thanks"). The coordinator owns the actual dismissal.
    var onFinish: (() -> Void)?

    // MARK: - UI

    private let backdropView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .mcSurface
        v.layer.cornerRadius = 24
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "The order has been completed."
        l.font = .poppins(.bold, size: 20)
        l.textColor = .mcPrimary
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        l.accessibilityIdentifier = "review_title"
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Please, rate the service."
        l.font = .poppins(.regular, size: 16)
        l.textColor = .mcTextPrimary
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let starsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

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

    private let remindButton = ReviewViewController.actionButton(
        title: "Remind me later", id: "review_remind_button", color: .mcAccent
    )
    private let noThanksButton = ReviewViewController.actionButton(
        title: "No, thanks", id: "review_nothanks_button",
        color: UIColor.mcTextPrimary.withAlphaComponent(0.5)
    )

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
        remindButton.addTarget(self, action: #selector(remindTapped), for: .touchUpInside)
        noThanksButton.addTarget(self, action: #selector(noThanksTapped), for: .touchUpInside)

        let separator1 = Self.hairline()
        let separator2 = Self.hairline()
        [titleLabel, subtitleLabel, starsStackView, separator1, remindButton, separator2, noThanksButton]
            .forEach { cardView.addSubview($0) }

        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(equalTo: view.topAnchor),
            backdropView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdropView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Full-width sheet anchored to the bottom.
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            starsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            starsStackView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            starsStackView.heightAnchor.constraint(equalToConstant: 40),

            separator1.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 24),
            separator1.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            separator1.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),

            remindButton.topAnchor.constraint(equalTo: separator1.bottomAnchor),
            remindButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            remindButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            remindButton.heightAnchor.constraint(equalToConstant: 56),

            separator2.topAnchor.constraint(equalTo: remindButton.bottomAnchor),
            separator2.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            separator2.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),

            noThanksButton.topAnchor.constraint(equalTo: separator2.bottomAnchor),
            noThanksButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            noThanksButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            noThanksButton.heightAnchor.constraint(equalToConstant: 56),
            noThanksButton.bottomAnchor.constraint(equalTo: cardView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
        ])
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
            button.setImage(Self.starImage(filled: button.tag <= rating), for: .normal)
        }
    }

    // MARK: - Factory helpers

    private static func starImage(filled: Bool) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
        return UIImage(systemName: filled ? "star.fill" : "star", withConfiguration: config)
    }

    private static func actionButton(title: String, id: String, color: UIColor) -> UIButton {
        var config = UIButton.Configuration.plain()
        var attr = AttributeContainer()
        attr.font = UIFont.poppins(.regular, size: 17)
        attr.foregroundColor = color
        config.attributedTitle = AttributedString(title, attributes: attr)
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.accessibilityIdentifier = id
        return b
    }

    private static func hairline() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.mcTextPrimary.withAlphaComponent(0.12)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return v
    }

    // MARK: - Actions

    @objc private func starTapped(_ sender: UIButton) {
        viewModel.selectRating(sender.tag)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.onFinish?()
        }
    }

    @objc private func remindTapped() { onFinish?() }
    @objc private func noThanksTapped() { onFinish?() }
}
