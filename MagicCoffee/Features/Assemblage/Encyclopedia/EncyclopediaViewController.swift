import UIKit

final class EncyclopediaViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: EncyclopediaViewModel
    var onSkip: (() -> Void)?
    var onNext: (() -> Void)?

    // MARK: - UI

    private let gradientLayer = CAGradientLayer()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.bold, size: 22)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let infoCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.regular, size: 15)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let skipButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Skip"
        config.baseForegroundColor = UIColor.white.withAlphaComponent(0.8)
        var attr = AttributeContainer()
        attr.font = UIFont.poppins(.medium, size: 16)
        config.attributedTitle = AttributedString("Skip", attributes: attr)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let nextButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Next"
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .mcPrimary
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 40, bottom: 14, trailing: 40)
        var attr = AttributeContainer()
        attr.font = UIFont.poppins(.bold, size: 16)
        config.attributedTitle = AttributedString("Next", attributes: attr)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    init(viewModel: EncyclopediaViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Coffee Encyclopedia"
        setupGradient()
        setupUI()
        populate()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup

    private func setupGradient() {
        gradientLayer.colors = [UIColor.mcAccent.cgColor, UIColor.mcPrimary.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        infoCard.addSubview(infoLabel)

        contentStack.addArrangedSubview(priceLabel)
        contentStack.addArrangedSubview(infoCard)

        // Bottom buttons row
        let buttonRow = UIStackView(arrangedSubviews: [skipButton, nextButton])
        buttonRow.axis = .horizontal
        buttonRow.alignment = .center
        buttonRow.distribution = .equalSpacing
        buttonRow.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(buttonRow)

        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),

            infoLabel.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            infoLabel.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -16),
        ])
    }

    private func populate() {
        priceLabel.text = viewModel.priceText
        infoLabel.text = viewModel.infoText
    }

    // MARK: - Actions

    @objc private func skipTapped() {
        onSkip?()
    }

    @objc private func nextTapped() {
        onNext?()
    }
}
