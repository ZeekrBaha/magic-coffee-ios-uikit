import Combine
import UIKit

final class StoreListViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: StoreListViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let backgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#314B59")
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Magic Coffee store"
        label.font = .poppins(.bold, size: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 88
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - Init

    init(viewModel: StoreListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadStores()
    }

    // MARK: - Setup

    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(backgroundView)
        view.addSubview(titleLabel)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        tableView.register(StoreCell.self, forCellReuseIdentifier: StoreCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func bindViewModel() {
        viewModel.$stores
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource

extension StoreListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.stores.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoreCell.reuseID, for: indexPath) as! StoreCell
        let store = viewModel.stores[indexPath.row]
        cell.configure(store: store, rowIndex: indexPath.row) { [weak self] in
            self?.viewModel.selectStore(store)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension StoreListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectStore(viewModel.stores[indexPath.row])
    }
}

// MARK: - StoreCell

private final class StoreCell: UITableViewCell {
    static let reuseID = "StoreCell"

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.bold, size: 16)
        label.textColor = .white
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.medium, size: 13)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let selectButton: UIButton = {
        let btn = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Select"
        config.baseForegroundColor = UIColor(hex: "#314B59")
        config.baseBackgroundColor = UIColor(hex: "#4ECDC4")
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
        config.cornerStyle = .fixed
        var titleAttr = AttributeContainer()
        titleAttr.font = UIFont.poppins(.bold, size: 14)
        config.attributedTitle = AttributedString("Select", attributes: titleAttr)
        btn.configuration = config
        btn.layer.cornerRadius = 8
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var onSelect: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(addressLabel)
        cardView.addSubview(selectButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: selectButton.leadingAnchor, constant: -8),

            addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            addressLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: selectButton.leadingAnchor, constant: -8),
            addressLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            selectButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            selectButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
        ])

        selectButton.addTarget(self, action: #selector(selectTapped), for: .touchUpInside)
    }

    func configure(store: CDStore, rowIndex: Int, onSelect: @escaping () -> Void) {
        nameLabel.text = store.name
        addressLabel.text = store.address
        self.onSelect = onSelect
        selectButton.accessibilityIdentifier = "store_row_\(rowIndex)"
    }

    @objc private func selectTapped() {
        onSelect?()
    }
}
