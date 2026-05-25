import UIKit

final class CountrySelectionViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: CountrySelectionViewModel
    var onCountrySelected: (() -> Void)?

    // MARK: - UI

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.rowHeight = 52
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - Init

    init(viewModel: CountrySelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Origin Country"
        view.backgroundColor = .mcSurface
        setupTableView()
    }

    // MARK: - Setup

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CountryCell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - UITableViewDataSource / Delegate

extension CountrySelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.countries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
        let country = viewModel.countries[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = country
        content.textProperties.font = .poppins(.regular, size: 16)
        content.textProperties.color = .mcTextPrimary
        cell.contentConfiguration = content
        // Teal highlight for selected country
        cell.backgroundColor = (country == viewModel.state.selectedCountry) ? UIColor.mcAccent.withAlphaComponent(0.15) : .mcSurface
        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chosen = viewModel.countries[indexPath.row]
        viewModel.select(chosen)
        tableView.reloadData()
        onCountrySelected?()
    }
}
