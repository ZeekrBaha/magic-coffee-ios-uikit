import Combine
import UIKit

final class HistoryOrdersViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: HistoryOrdersViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .mcCardBg
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.accessibilityIdentifier = "history_orders_table"
        return tv
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No order history"
        label.font = .poppins(.regular, size: 16)
        label.textColor = .mcPrimary
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(viewModel: HistoryOrdersViewModel) {
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
        viewModel.loadOrders()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadOrders()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .mcCardBg
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        tableView.register(OrderCell.self, forCellReuseIdentifier: OrderCell.reuseID)
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func bindViewModel() {
        viewModel.$orders
            .receive(on: DispatchQueue.main)
            .sink { [weak self] orders in
                guard let self else { return }
                self.emptyLabel.isHidden = !orders.isEmpty
                self.tableView.isHidden = orders.isEmpty
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource

extension HistoryOrdersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: OrderCell.reuseID,
            for: indexPath
        ) as! OrderCell
        cell.configure(with: viewModel.orders[indexPath.row], badgeStyle: .completed)
        return cell
    }
}
