import UIKit

final class BaristaSelectionViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: BaristaSelectionViewModel
    var onBaristaSelected: (() -> Void)?

    // MARK: - UI

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.rowHeight = 72
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - Init

    init(viewModel: BaristaSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Barista"
        view.backgroundColor = .mcSurface
        setupTableView()
        setupCallbacks()
        viewModel.loadBaristas()
    }

    // MARK: - Setup

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BaristaCell.self, forCellReuseIdentifier: BaristaCell.reuseID)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupCallbacks() {
        viewModel.onBaristasLoaded = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.onError = { _ in
            // Barista list stays empty on fetch failure; no recovery UI is specified.
        }
    }
}

// MARK: - UITableViewDataSource / Delegate

extension BaristaSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.baristas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BaristaCell.reuseID, for: indexPath) as! BaristaCell
        let barista = viewModel.baristas[indexPath.row]
        cell.configure(with: barista)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.select(baristaAt: indexPath.row)
        onBaristaSelected?()
    }
}

// MARK: - BaristaCell

private final class BaristaCell: UITableViewCell {
    static let reuseID = "BaristaCell"

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.crop.circle")
        iv.tintColor = .mcAccent
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 24
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.bold, size: 15)
        label.textColor = .mcTextPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let specialtyLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.regular, size: 13)
        label.textColor = .mcTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let availabilityDot: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    private func setupLayout() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(specialtyLabel)
        contentView.addSubview(availabilityDot)

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            avatarImageView.heightAnchor.constraint(equalToConstant: 48),

            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: availabilityDot.leadingAnchor, constant: -8),

            specialtyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            specialtyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            specialtyLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            availabilityDot.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            availabilityDot.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            availabilityDot.widthAnchor.constraint(equalToConstant: 12),
            availabilityDot.heightAnchor.constraint(equalToConstant: 12),
        ])
    }

    func configure(with barista: CDBarista) {
        nameLabel.text = barista.name
        specialtyLabel.text = barista.specialty ?? ""
        availabilityDot.backgroundColor = barista.isAvailable ? .systemGreen : .systemRed
    }
}
