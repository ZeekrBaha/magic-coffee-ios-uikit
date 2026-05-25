import Combine
import UIKit

final class RewardsViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: RewardsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI — Stamp Card

    private let stampCardContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .mcSurface
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 8
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.accessibilityIdentifier = "rewards_stamp_card"
        return v
    }()

    private let stampCardTitle: UILabel = {
        let l = UILabel()
        l.text = "Loyalty Card"
        l.font = .poppins(.bold, size: 16)
        l.textColor = .mcPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let stampGridStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let stampCountLabel: UILabel = {
        let l = UILabel()
        l.font = .poppins(.regular, size: 13)
        l.textColor = .mcPrimary
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - UI — Points & Redeem

    private let pointsLabel: UILabel = {
        let l = UILabel()
        l.font = .poppins(.bold, size: 22)
        l.textColor = .mcAccent
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.accessibilityIdentifier = "rewards_points_label"
        return l
    }()

    private let redeemButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Redeem"
        config.baseBackgroundColor = .mcAccent
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFont.poppins(.bold, size: 16)
            return out
        }
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 40, bottom: 14, trailing: 40)
        let b = UIButton(configuration: config)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        b.accessibilityIdentifier = "rewards_redeem_button"
        return b
    }()

    // MARK: - UI — History

    private let historyTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Reward History"
        l.font = .poppins(.bold, size: 16)
        l.textColor = .mcPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let historyTable: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.backgroundColor = .clear
        t.separatorStyle = .none
        t.register(RewardHistoryCell.self, forCellReuseIdentifier: RewardHistoryCell.reuseID)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.accessibilityIdentifier = "rewards_history_table"
        return t
    }()

    private let emptyHistoryLabel: UILabel = {
        let l = UILabel()
        l.text = "No reward history yet."
        l.font = .poppins(.regular, size: 14)
        l.textColor = .mcPrimary
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isHidden = true
        return l
    }()

    // MARK: - Init

    init(viewModel: RewardsViewModel) {
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
        setupNavigationBar()
        bindViewModel()
        historyTable.dataSource = self
        redeemButton.addTarget(self, action: #selector(redeemTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "Rewards"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.poppins(.bold, size: 18),
            .foregroundColor: UIColor.mcPrimary,
        ]
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backgroundColor = .mcSurface
    }

    private func setupUI() {
        view.backgroundColor = .mcCardBg

        // Build stamp grid: 2 rows × 4 columns
        let row1 = makeStampRow(tag: 0)
        let row2 = makeStampRow(tag: 1)
        stampGridStack.addArrangedSubview(row1)
        stampGridStack.addArrangedSubview(row2)

        stampCardContainer.addSubview(stampCardTitle)
        stampCardContainer.addSubview(stampGridStack)
        stampCardContainer.addSubview(stampCountLabel)

        view.addSubview(stampCardContainer)
        view.addSubview(pointsLabel)
        view.addSubview(redeemButton)
        view.addSubview(historyTitleLabel)
        view.addSubview(historyTable)
        view.addSubview(emptyHistoryLabel)

        NSLayoutConstraint.activate([
            // Stamp card container
            stampCardContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stampCardContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stampCardContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            stampCardTitle.topAnchor.constraint(equalTo: stampCardContainer.topAnchor, constant: 16),
            stampCardTitle.leadingAnchor.constraint(equalTo: stampCardContainer.leadingAnchor, constant: 16),

            stampGridStack.topAnchor.constraint(equalTo: stampCardTitle.bottomAnchor, constant: 14),
            stampGridStack.leadingAnchor.constraint(equalTo: stampCardContainer.leadingAnchor, constant: 16),
            stampGridStack.trailingAnchor.constraint(equalTo: stampCardContainer.trailingAnchor, constant: -16),
            stampGridStack.heightAnchor.constraint(equalToConstant: 80),

            stampCountLabel.topAnchor.constraint(equalTo: stampGridStack.bottomAnchor, constant: 10),
            stampCountLabel.centerXAnchor.constraint(equalTo: stampCardContainer.centerXAnchor),
            stampCountLabel.bottomAnchor.constraint(equalTo: stampCardContainer.bottomAnchor, constant: -16),

            // Points label
            pointsLabel.topAnchor.constraint(equalTo: stampCardContainer.bottomAnchor, constant: 20),
            pointsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Redeem button
            redeemButton.topAnchor.constraint(equalTo: pointsLabel.bottomAnchor, constant: 14),
            redeemButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // History title
            historyTitleLabel.topAnchor.constraint(equalTo: redeemButton.bottomAnchor, constant: 28),
            historyTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            // Empty label
            emptyHistoryLabel.topAnchor.constraint(equalTo: historyTitleLabel.bottomAnchor, constant: 20),
            emptyHistoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // History table
            historyTable.topAnchor.constraint(equalTo: historyTitleLabel.bottomAnchor, constant: 8),
            historyTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            historyTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            historyTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    /// Creates one row of 4 stamp circles. `tag` differentiates row 0 and row 1.
    private func makeStampRow(tag: Int) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually
        row.tag = tag
        for i in 0..<4 {
            let circle = makeStampCircle(index: tag * 4 + i)
            row.addArrangedSubview(circle)
        }
        return row
    }

    private func makeStampCircle(index: Int) -> UIView {
        let container = UIView()
        container.tag = index + 100  // offset to avoid conflict with row tags
        container.translatesAutoresizingMaskIntoConstraints = false

        let circle = UIView()
        circle.layer.cornerRadius = 18
        circle.layer.borderWidth = 2
        circle.layer.borderColor = UIColor.mcAccent.cgColor
        circle.backgroundColor = .clear
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.tag = 1  // inner circle identifier
        container.addSubview(circle)

        NSLayoutConstraint.activate([
            circle.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: 36),
            circle.heightAnchor.constraint(equalToConstant: 36),
        ])
        return container
    }

    // MARK: - Bind

    private func bindViewModel() {
        viewModel.$stamps
            .combineLatest(viewModel.$maxStamps, viewModel.$totalPoints, viewModel.$history)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stamps, maxStamps, points, history in
                self?.updateStampGrid(stamps: stamps, maxStamps: maxStamps)
                self?.stampCountLabel.text = "\(stamps)/\(maxStamps) stamps"
                self?.pointsLabel.text = "My Points: \(points)"
                self?.updateHistory(history)
            }
            .store(in: &cancellables)
    }

    private func updateStampGrid(stamps: Int16, maxStamps: Int16) {
        for row in stampGridStack.arrangedSubviews {
            for container in row.subviews {
                guard let circle = container.viewWithTag(1) else { continue }
                let index = container.tag - 100
                if index < stamps {
                    circle.backgroundColor = .mcAccent
                    circle.layer.borderColor = UIColor.mcAccent.cgColor
                } else {
                    circle.backgroundColor = .clear
                    circle.layer.borderColor = UIColor.mcAccent.cgColor
                }
            }
        }
    }

    private func updateHistory(_ history: [CDRewardHistory]) {
        let hasItems = !history.isEmpty
        emptyHistoryLabel.isHidden = hasItems
        historyTable.isHidden = !hasItems
        historyTable.reloadData()
    }

    // MARK: - Actions

    @objc private func redeemTapped() {
        viewModel.redeemTapped()
    }
}

// MARK: - UITableViewDataSource

extension RewardsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RewardHistoryCell.reuseID, for: indexPath) as! RewardHistoryCell
        cell.configure(with: viewModel.history[indexPath.row])
        return cell
    }
}

// MARK: - RewardHistoryCell

final class RewardHistoryCell: UITableViewCell {
    static let reuseID = "RewardHistoryCell"

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .mcSurface
        v.layer.cornerRadius = 10
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.05
        v.layer.shadowRadius = 4
        v.layer.shadowOffset = CGSize(width: 0, height: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .poppins(.medium, size: 14)
        l.textColor = .mcPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .poppins(.regular, size: 12)
        l.textColor = .mcPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let pointsLabel: UILabel = {
        let l = UILabel()
        l.font = .poppins(.bold, size: 14)
        l.textColor = .mcAccent
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)
        [nameLabel, dateLabel, pointsLabel].forEach { cardView.addSubview($0) }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: pointsLabel.leadingAnchor, constant: -8),

            pointsLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            pointsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            dateLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    func configure(with item: CDRewardHistory) {
        nameLabel.text = item.productName
        pointsLabel.text = "-\(item.points) pts"

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = item.date.map { formatter.string(from: $0) } ?? ""
    }
}
