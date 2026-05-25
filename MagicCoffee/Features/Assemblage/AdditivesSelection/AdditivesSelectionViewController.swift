import UIKit

final class AdditivesSelectionViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: AdditivesSelectionViewModel
    var onDone: (() -> Void)?

    // MARK: - UI

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.rowHeight = 52
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let doneButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Done"
        config.baseBackgroundColor = .mcAccent
        config.baseForegroundColor = .mcPrimary
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 40, bottom: 14, trailing: 40)
        var attr = AttributeContainer()
        attr.font = UIFont.poppins(.bold, size: 16)
        config.attributedTitle = AttributedString("Done", attributes: attr)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    init(viewModel: AdditivesSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Additives"
        view.backgroundColor = .mcSurface
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(doneButton)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AdditiveCell")

        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),

            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
    }

    // MARK: - Actions

    @objc private func doneTapped() {
        onDone?()
    }
}

// MARK: - UITableViewDataSource / Delegate

extension AdditivesSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.additives.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdditiveCell", for: indexPath)
        let additive = viewModel.additives[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = additive
        content.textProperties.font = .poppins(.regular, size: 16)
        content.textProperties.color = .mcTextPrimary
        cell.contentConfiguration = content
        cell.accessoryType = viewModel.isSelected(additive) ? .checkmark : .none
        cell.tintColor = .mcAccent
        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let additive = viewModel.additives[indexPath.row]
        viewModel.toggle(additive)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
