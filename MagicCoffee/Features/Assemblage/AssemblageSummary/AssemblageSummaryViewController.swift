import UIKit

final class AssemblageSummaryViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: AssemblageSummaryViewModel
    var onProceed: (() -> Void)?

    // Section indices
    private enum Section: Int, CaseIterable {
        case settings = 0
        case items = 1
    }

    private var itemRows: [AssemblageSummaryViewModel.ItemRow] = []

    // MARK: - UI

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let proceedButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Proceed to Order"
        config.baseBackgroundColor = .mcAccent
        config.baseForegroundColor = .mcPrimary
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        var attr = AttributeContainer()
        attr.font = UIFont.poppins(.bold, size: 16)
        config.attributedTitle = AttributedString("Proceed to Order", attributes: attr)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    init(viewModel: AssemblageSummaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Summary"
        view.backgroundColor = .mcSurface
        itemRows = viewModel.itemRows
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(proceedButton)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reuseID)

        proceedButton.addTarget(self, action: #selector(proceedTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: proceedButton.topAnchor, constant: -16),

            proceedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            proceedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
    }

    // MARK: - Actions

    @objc private func proceedTapped() {
        onProceed?()
    }
}

// MARK: - UITableViewDataSource / Delegate

extension AssemblageSummaryViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .settings: return viewModel.settingsRows.count
        case .items: return itemRows.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .settings: return "Settings"
        case .items: return "Items"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .settings:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            let row = viewModel.settingsRows[indexPath.row]
            var content = cell.defaultContentConfiguration()
            content.text = row.title
            content.secondaryText = row.value
            content.textProperties.font = .poppins(.medium, size: 15)
            content.secondaryTextProperties.font = .poppins(.regular, size: 15)
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            return cell
        case .items:
            let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reuseID, for: indexPath) as! ItemCell
            cell.configure(with: itemRows[indexPath.row])
            return cell
        }
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard Section(rawValue: indexPath.section) == .items,
              editingStyle == .delete else { return }
        itemRows.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool {
        Section(rawValue: indexPath.section) == .items
    }
}

// MARK: - ItemCell

private final class ItemCell: UITableViewCell {
    static let reuseID = "ItemCell"

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.medium, size: 15)
        label.textColor = .mcTextPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.regular, size: 14)
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
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    private func setupLayout() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(priceLabel)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

            quantityLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            quantityLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            quantityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(with item: AssemblageSummaryViewModel.ItemRow) {
        nameLabel.text = item.name
        quantityLabel.text = "Qty: \(item.quantity)"
        priceLabel.text = String(format: "£%.2f", item.price * Double(item.quantity))
    }
}
