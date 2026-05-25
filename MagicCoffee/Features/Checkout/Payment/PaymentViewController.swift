import Combine
import UIKit

final class PaymentViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: PaymentViewModel
    var onOrderPlaced: ((CDOrder) -> Void)?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.medium, size: 15)
        label.textColor = .mcTextPrimary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let onlineOptionView = PaymentOptionRow(
        title: "Online (Apple Pay / Assist)",
        accessibilityID: "payment_online_option"
    )

    private let cardOptionView = PaymentOptionRow(
        title: "Credit Card (Visa / MC)",
        accessibilityID: "payment_card_option"
    )

    private let payButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .mcAccent
        config.baseForegroundColor = .mcPrimary
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        var attr = AttributeContainer()
        attr.font = UIFont.poppins(.bold, size: 16)
        config.attributedTitle = AttributedString("Pay Now", attributes: attr)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "payment_pay_button"
        return btn
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Init

    init(viewModel: PaymentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.onOrderPlaced = { [weak self] order in
            self?.onOrderPlaced?(order)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Payment"
        view.backgroundColor = .mcSurface
        setupUI()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupUI() {
        let sectionLabel = UILabel()
        sectionLabel.text = "Pickup Location"
        sectionLabel.font = .poppins(.bold, size: 13)
        sectionLabel.textColor = .mcTextSecondary
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false

        let paymentSectionLabel = UILabel()
        paymentSectionLabel.text = "Payment Method"
        paymentSectionLabel.font = .poppins(.bold, size: 13)
        paymentSectionLabel.textColor = .mcTextSecondary
        paymentSectionLabel.translatesAutoresizingMaskIntoConstraints = false

        addressLabel.text = viewModel.storeAddressText

        [sectionLabel, addressLabel, paymentSectionLabel,
         onlineOptionView, cardOptionView, payButton, activityIndicator].forEach {
            view.addSubview($0)
        }

        let onlineTap = UITapGestureRecognizer(target: self, action: #selector(onlineOptionTapped))
        let cardTap = UITapGestureRecognizer(target: self, action: #selector(cardOptionTapped))
        onlineOptionView.addGestureRecognizer(onlineTap)
        cardOptionView.addGestureRecognizer(cardTap)
        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            sectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            addressLabel.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 8),
            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            paymentSectionLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 32),
            paymentSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            onlineOptionView.topAnchor.constraint(equalTo: paymentSectionLabel.bottomAnchor, constant: 12),
            onlineOptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            onlineOptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            onlineOptionView.heightAnchor.constraint(equalToConstant: 56),

            cardOptionView.topAnchor.constraint(equalTo: onlineOptionView.bottomAnchor, constant: 12),
            cardOptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardOptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardOptionView.heightAnchor.constraint(equalToConstant: 56),

            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -12),
        ])
    }

    private func bindViewModel() {
        viewModel.$selectedOption
            .receive(on: DispatchQueue.main)
            .sink { [weak self] option in
                self?.onlineOptionView.setSelected(option == .online)
                self?.cardOptionView.setSelected(option == .card)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                if loading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
                self?.payButton.isEnabled = !loading
            }
            .store(in: &cancellables)

        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                let alert = UIAlertController(
                    title: "Payment Failed",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func onlineOptionTapped() {
        viewModel.select(option: .online)
    }

    @objc private func cardOptionTapped() {
        viewModel.select(option: .card)
    }

    @objc private func payTapped() {
        viewModel.pay()
    }
}

// MARK: - PaymentOptionRow

private final class PaymentOptionRow: UIView {

    private let radioView: UIView = {
        let v = UIView()
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.mcPrimary.cgColor
        v.layer.cornerRadius = 11
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let radioFillView: UIView = {
        let v = UIView()
        v.backgroundColor = .mcAccent
        v.layer.cornerRadius = 7
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.medium, size: 15)
        label.textColor = .mcTextPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(title: String, accessibilityID: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityIdentifier = accessibilityID
        titleLabel.text = title
        setupLayout()
        backgroundColor = .mcCardBg
        layer.cornerRadius = 12
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    private func setupLayout() {
        addSubview(radioView)
        radioView.addSubview(radioFillView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            radioView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            radioView.centerYAnchor.constraint(equalTo: centerYAnchor),
            radioView.widthAnchor.constraint(equalToConstant: 22),
            radioView.heightAnchor.constraint(equalToConstant: 22),

            radioFillView.centerXAnchor.constraint(equalTo: radioView.centerXAnchor),
            radioFillView.centerYAnchor.constraint(equalTo: radioView.centerYAnchor),
            radioFillView.widthAnchor.constraint(equalToConstant: 14),
            radioFillView.heightAnchor.constraint(equalToConstant: 14),

            titleLabel.leadingAnchor.constraint(equalTo: radioView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }

    func setSelected(_ selected: Bool) {
        radioFillView.isHidden = !selected
        radioView.layer.borderColor = selected ? UIColor.mcAccent.cgColor : UIColor.mcPrimary.cgColor
    }
}
