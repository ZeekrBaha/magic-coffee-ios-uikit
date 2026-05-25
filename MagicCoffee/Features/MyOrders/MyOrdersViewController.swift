import UIKit

// MARK: - OrderCell (shared by both Ongoing and History tables)

enum OrderBadgeStyle {
    case ongoing
    case completed
}

final class OrderCell: UITableViewCell {
    static let reuseID = "OrderCell"

    // MARK: - UI

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .mcSurface
        v.layer.cornerRadius = 12
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 6
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let storeLabel: UILabel = {
        let l = UILabel()
        l.font = .poppins(.bold, size: 15)
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

    private let itemsLabel: UILabel = {
        let l = UILabel()
        l.font = .poppins(.regular, size: 13)
        l.textColor = .mcPrimary
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let totalLabel: UILabel = {
        let l = UILabel()
        l.font = .poppins(.medium, size: 14)
        l.textColor = .mcAccent
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let badgeButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.poppins(.medium, size: 12)
            return outgoing
        }
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
        let b = UIButton(configuration: config)
        b.layer.cornerRadius = 10
        b.isUserInteractionEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)

        [storeLabel, dateLabel, itemsLabel, totalLabel, badgeButton].forEach {
            cardView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            storeLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            storeLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            storeLabel.trailingAnchor.constraint(equalTo: badgeButton.leadingAnchor, constant: -8),

            badgeButton.centerYAnchor.constraint(equalTo: storeLabel.centerYAnchor),
            badgeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            dateLabel.topAnchor.constraint(equalTo: storeLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            itemsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 6),
            itemsLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            itemsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            totalLabel.topAnchor.constraint(equalTo: itemsLabel.bottomAnchor, constant: 8),
            totalLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            totalLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),
        ])
    }

    // MARK: - Configure

    func configure(with order: CDOrder, badgeStyle: OrderBadgeStyle) {
        storeLabel.text = order.store?.name ?? "Unknown Store"

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = order.createdAt.map { formatter.string(from: $0) } ?? ""

        // Build items summary from CDOrderItems.
        let itemSet = order.items as? Set<CDOrderItem> ?? []
        let names = itemSet.compactMap { $0.product?.name }
        itemsLabel.text = names.isEmpty ? "–" : names.joined(separator: ", ")

        let amount = order.totalAmount?.doubleValue ?? 0
        totalLabel.text = String(format: "£%.2f", amount)

        var config = badgeButton.configuration ?? UIButton.Configuration.filled()
        switch badgeStyle {
        case .ongoing:
            config.title = "Order"
            config.baseBackgroundColor = .mcAccent
            config.baseForegroundColor = .white
        case .completed:
            config.title = "Completed"
            config.baseBackgroundColor = UIColor.systemGray5
            config.baseForegroundColor = .mcPrimary
        }
        badgeButton.configuration = config
    }
}

// MARK: - MyOrdersViewController

/// UIPageViewController host for Ongoing and History order lists.
final class MyOrdersViewController: UIViewController {

    // MARK: - Properties

    private let orderService: OrderService

    private lazy var ongoingVC: OngoingOrdersViewController = {
        let vm = OngoingOrdersViewModel(orderService: orderService)
        return OngoingOrdersViewController(viewModel: vm)
    }()

    private lazy var historyVC: HistoryOrdersViewController = {
        let vm = HistoryOrdersViewModel(orderService: orderService)
        return HistoryOrdersViewController(viewModel: vm)
    }()

    private lazy var pages: [UIViewController] = [ongoingVC, historyVC]

    private let pageVC: UIPageViewController = {
        let pvc = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        return pvc
    }()

    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Ongoing", "History"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .mcAccent
        sc.setTitleTextAttributes(
            [.foregroundColor: UIColor.white, .font: UIFont.poppins(.medium, size: 13)],
            for: .selected
        )
        sc.setTitleTextAttributes(
            [.foregroundColor: UIColor.mcPrimary, .font: UIFont.poppins(.regular, size: 13)],
            for: .normal
        )
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.accessibilityIdentifier = "my_orders_segmented"
        return sc
    }()

    // MARK: - Init

    init(orderService: OrderService = .shared) {
        self.orderService = orderService
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
        setupPageViewController()
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "My Orders"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.poppins(.bold, size: 18),
            .foregroundColor: UIColor.mcPrimary,
        ]
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backgroundColor = .mcSurface
    }

    private func setupUI() {
        view.backgroundColor = .mcCardBg
        view.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    private func setupPageViewController() {
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        pageVC.didMove(toParent: self)
        pageVC.dataSource = self
        pageVC.delegate = self

        pageVC.setViewControllers([ongoingVC], direction: .forward, animated: false)
    }

    // MARK: - Actions

    @objc private func segmentChanged() {
        let index = segmentedControl.selectedSegmentIndex
        let targetVC = pages[index]
        let direction: UIPageViewController.NavigationDirection = index == 0 ? .reverse : .forward
        pageVC.setViewControllers([targetVC], direction: direction, animated: true)
    }
}

// MARK: - UIPageViewControllerDataSource

extension MyOrdersViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension MyOrdersViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let current = pageViewController.viewControllers?.first,
              let index = pages.firstIndex(of: current) else { return }
        segmentedControl.selectedSegmentIndex = index
    }
}
