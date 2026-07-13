import UIKit

final class PrePaymentListViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: PrePaymentListViewModel
    var onNext: (() -> Void)?

    // MARK: - UI

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 80
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.accessibilityIdentifier = "prepayment_items_table"
        return tv
    }()

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.bold, size: 17)
        label.textColor = .mcPrimary
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "prepayment_total_label"
        return label
    }()

    private let nextButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .mcAccent
        config.baseForegroundColor = .mcPrimary
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        var attr = AttributeContainer()
        attr.font = UIFont.poppins(.bold, size: 16)
        config.attributedTitle = AttributedString("Next →", attributes: attr)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "prepayment_next_button"
        return btn
    }()

    private let totalContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .mcCardBg
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Init

    init(viewModel: PrePaymentListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Order Review"
        view.backgroundColor = .mcSurface
        setupUI()
        totalLabel.text = viewModel.totalText
    }

    // MARK: - Setup

    private func setupUI() {
        tableView.dataSource = self
        tableView.register(PrePaymentItemCell.self, forCellReuseIdentifier: PrePaymentItemCell.reuseID)

        totalContainer.addSubview(totalLabel)
        view.addSubview(tableView)
        view.addSubview(totalContainer)
        view.addSubview(nextButton)

        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: totalContainer.topAnchor),

            totalContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalContainer.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -16),
            totalContainer.heightAnchor.constraint(equalToConstant: 48),

            totalLabel.trailingAnchor.constraint(equalTo: totalContainer.trailingAnchor, constant: -16),
            totalLabel.centerYAnchor.constraint(equalTo: totalContainer.centerYAnchor),

            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
    }

    // MARK: - Actions

    @objc private func nextTapped() {
        onNext?()
    }
}

// MARK: - UITableViewDataSource

extension PrePaymentListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.itemRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PrePaymentItemCell.reuseID,
            for: indexPath
            // swiftlint:disable:next force_cast
        ) as! PrePaymentItemCell
        cell.configure(with: viewModel.itemRows[indexPath.row])
        return cell
    }
}

// MARK: - PrePaymentItemCell

private final class PrePaymentItemCell: UITableViewCell {
    static let reuseID = "PrePaymentItemCell"

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.bold, size: 15)
        label.textColor = .mcTextPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let customizationLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.regular, size: 13)
        label.textColor = .mcTextSecondary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.regular, size: 13)
        label.textColor = .mcTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.bold, size: 15)
        label.textColor = .mcPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    private func setupLayout() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(customizationLabel)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(priceLabel)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -8),

            customizationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            customizationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            customizationLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            quantityLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            quantityLabel.topAnchor.constraint(equalTo: customizationLabel.bottomAnchor, constant: 4),
            quantityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(with row: PrePaymentListViewModel.ItemRow) {
        nameLabel.text = row.name
        quantityLabel.text = "Qty: \(row.quantity)"
        priceLabel.text = String(format: "£%.2f", row.price * Double(row.quantity))

        var customizations: [String] = []
        if let milk = row.milk { customizations.append("Milk: \(milk)") }
        if let syrup = row.syrup { customizations.append("Syrup: \(syrup)") }
        if !row.additives.isEmpty { customizations.append("+ \(row.additives.joined(separator: ", "))") }
        customizationLabel.text = customizations.joined(separator: " · ")
    }
}
