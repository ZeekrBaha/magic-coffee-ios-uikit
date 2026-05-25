import UIKit

final class ConfirmationViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: ConfirmationViewModel
    var onBackToHome: (() -> Void)?
    var onShowReview: (() -> Void)?

    // MARK: - UI

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 72, weight: .medium)
        iv.image = UIImage(systemName: "cup.and.saucer.fill", withConfiguration: config)
        iv.tintColor = .mcAccent
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let orderedLabel: UILabel = {
        let label = UILabel()
        label.text = "Ordered!"
        label.font = .poppins(.bold, size: 28)
        label.textColor = .mcPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "confirmation_ordered_label"
        return label
    }()

    private let storeLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.medium, size: 15)
        label.textColor = .mcTextPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let estimatedTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.regular, size: 14)
        label.textColor = .mcTextSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let qrImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = UIColor.mcCardBg
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let qrFallbackLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.regular, size: 11)
        label.textColor = .mcTextPrimary
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let backButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .mcAccent
        config.baseForegroundColor = .mcPrimary
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        var attr = AttributeContainer()
        attr.font = UIFont.poppins(.bold, size: 16)
        config.attributedTitle = AttributedString("Back to Home", attributes: attr)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "confirmation_back_button"
        return btn
    }()

    // MARK: - Init

    init(viewModel: ConfirmationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Confirmation"
        view.backgroundColor = .mcSurface
        // Hide the back button so users don't accidentally go back.
        navigationItem.hidesBackButton = true
        setupUI()
        populateContent()
        triggerReviewModal()
    }

    // MARK: - Setup

    private func setupUI() {
        [iconImageView, orderedLabel, storeLabel, estimatedTimeLabel,
         qrImageView, qrFallbackLabel, backButton].forEach { view.addSubview($0) }

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),

            orderedLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            orderedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orderedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            orderedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            storeLabel.topAnchor.constraint(equalTo: orderedLabel.bottomAnchor, constant: 12),
            storeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            storeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            storeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            estimatedTimeLabel.topAnchor.constraint(equalTo: storeLabel.bottomAnchor, constant: 6),
            estimatedTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            qrImageView.topAnchor.constraint(equalTo: estimatedTimeLabel.bottomAnchor, constant: 32),
            qrImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            qrImageView.widthAnchor.constraint(equalToConstant: 180),
            qrImageView.heightAnchor.constraint(equalToConstant: 180),

            qrFallbackLabel.topAnchor.constraint(equalTo: qrImageView.bottomAnchor, constant: 8),
            qrFallbackLabel.leadingAnchor.constraint(equalTo: qrImageView.leadingAnchor),
            qrFallbackLabel.trailingAnchor.constraint(equalTo: qrImageView.trailingAnchor),

            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
    }

    private func populateContent() {
        storeLabel.text = viewModel.storeNameText
        estimatedTimeLabel.text = "Ready in \(viewModel.estimatedTimeText)"

        // Try to render a real QR code from the order ID.
        let qrSize = CGSize(width: 180, height: 180)
        if let qrImage = viewModel.generateQRImage(size: qrSize) {
            qrImageView.image = qrImage
        } else {
            // Fallback: dark square with the pickup code.
            qrImageView.backgroundColor = .mcPrimary
            qrFallbackLabel.text = "Order ID\n\(viewModel.pickupCodeText)"
            qrFallbackLabel.textColor = .white
        }
    }

    private func triggerReviewModal() {
        // Trigger the review modal after a short delay to let the screen settle.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.onShowReview?()
        }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        onBackToHome?()
    }
}
