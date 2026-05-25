import UIKit

final class SyrupSelectionViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: SyrupSelectionViewModel
    var onDismiss: (() -> Void)?

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose syrup"
        label.font = .poppins(.bold, size: 18)
        label.textColor = .mcPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .singleLine
        tv.rowHeight = 52
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let cancelButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Cancel"
        config.baseForegroundColor = .systemRed
        var attr = AttributeContainer()
        attr.font = UIFont.poppins(.medium, size: 16)
        config.attributedTitle = AttributedString("Cancel", attributes: attr)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    init(viewModel: SyrupSelectionViewModel) {
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
        setupSheet()
    }

    // MARK: - Setup

    private func setupSheet() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
    }

    private func setupUI() {
        view.backgroundColor = .mcSurface

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(cancelButton)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SyrupCell")

        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(viewModel.options.count) * 52),

            cancelButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource / Delegate

extension SyrupSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SyrupCell", for: indexPath)
        let option = viewModel.options[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = option
        content.textProperties.font = .poppins(.regular, size: 16)
        content.textProperties.color = .mcTextPrimary
        cell.contentConfiguration = content
        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chosen = viewModel.options[indexPath.row]
        viewModel.select(chosen)
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
}
