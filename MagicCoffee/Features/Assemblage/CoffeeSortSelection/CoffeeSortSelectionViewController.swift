import UIKit

final class CoffeeSortSelectionViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: CoffeeSortSelectionViewModel
    var onSortSelected: (() -> Void)?

    // MARK: - UI

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.rowHeight = 52
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - Init

    init(viewModel: CoffeeSortSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Coffee Sort"
        view.backgroundColor = .mcSurface
        setupTableView()
    }

    // MARK: - Setup

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SortCell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - UITableViewDataSource / Delegate

extension CoffeeSortSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sorts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath)
        let sort = viewModel.sorts[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = sort
        content.textProperties.font = .poppins(.regular, size: 16)
        content.textProperties.color = .mcTextPrimary
        cell.contentConfiguration = content
        // Single checkmark on selected sort
        cell.accessoryType = (sort == viewModel.state.selectedCoffeeSort) ? .checkmark : .none
        cell.tintColor = .mcAccent
        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chosen = viewModel.sorts[indexPath.row]
        viewModel.select(chosen)
        tableView.reloadData()
        onSortSelected?()
    }
}
