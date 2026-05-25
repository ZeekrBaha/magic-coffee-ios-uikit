import Combine
import UIKit

final class ProductDetailViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: ProductDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = UIColor.mcCardBg
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.bold, size: 22)
        label.textColor = .mcTextPrimary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let sizeSectionLabel = ProductDetailViewController.makeSectionLabel("Size")

    private let sizeSegment: UISegmentedControl = {
        let items = CoffeeSize.allCases.map { $0.rawValue }
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 1  // "One shot" default
        sc.selectedSegmentTintColor = .mcAccent
        sc.setTitleTextAttributes([.foregroundColor: UIColor.mcPrimary, .font: UIFont.poppins(.medium, size: 12)], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.poppins(.bold, size: 12)], for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let serviceSectionLabel = ProductDetailViewController.makeSectionLabel("Service")

    private let serviceSegment: UISegmentedControl = {
        let items = ServiceType.allCases.map { $0.rawValue }
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .mcAccent
        sc.setTitleTextAttributes([.foregroundColor: UIColor.mcPrimary, .font: UIFont.poppins(.medium, size: 13)], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.poppins(.bold, size: 13)], for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let volumeLabel: UILabel = {
        let label = UILabel()
        label.text = "350 ml"
        label.font = .poppins(.regular, size: 14)
        label.textColor = .mcTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timeSectionLabel = ProductDetailViewController.makeSectionLabel("Time")

    private let timeSegment: UISegmentedControl = {
        let items = TimeChoice.allCases.map { $0.rawValue }
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .mcAccent
        sc.setTitleTextAttributes([.foregroundColor: UIColor.mcPrimary, .font: UIFont.poppins(.medium, size: 13)], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.poppins(.bold, size: 13)], for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let assemblageButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Assemblage"
        config.baseBackgroundColor = .mcAccent
        config.baseForegroundColor = .mcPrimary
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 32, bottom: 14, trailing: 32)
        var titleAttr = AttributeContainer()
        titleAttr.font = UIFont.poppins(.bold, size: 16)
        config.attributedTitle = AttributedString("Assemblage", attributes: titleAttr)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let totalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.bold, size: 18)
        label.textColor = .mcPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nextButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Next →"
        config.baseBackgroundColor = .mcPrimary
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        var titleAttr = AttributeContainer()
        titleAttr.font = UIFont.poppins(.bold, size: 16)
        config.attributedTitle = AttributedString("Next →", attributes: titleAttr)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    init(viewModel: ProductDetailViewModel) {
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
        populate()
        bindViewModel()
        setupActions()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .mcSurface
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])

        // Image
        contentStack.addArrangedSubview(productImageView)
        productImageView.heightAnchor.constraint(equalToConstant: 250).isActive = true

        // Name
        contentStack.addArrangedSubview(nameLabel)

        // Size
        contentStack.addArrangedSubview(sizeSectionLabel)
        contentStack.addArrangedSubview(sizeSegment)

        // Volume
        contentStack.addArrangedSubview(volumeLabel)

        // Service
        contentStack.addArrangedSubview(serviceSectionLabel)
        contentStack.addArrangedSubview(serviceSegment)

        // Time
        contentStack.addArrangedSubview(timeSectionLabel)
        contentStack.addArrangedSubview(timeSegment)

        // Spacer
        let spacer = UIView()
        contentStack.addArrangedSubview(spacer)
        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true

        // Assemblage button (centered)
        let assemblageContainer = UIView()
        assemblageContainer.translatesAutoresizingMaskIntoConstraints = false
        assemblageContainer.addSubview(assemblageButton)
        NSLayoutConstraint.activate([
            assemblageButton.centerXAnchor.constraint(equalTo: assemblageContainer.centerXAnchor),
            assemblageButton.topAnchor.constraint(equalTo: assemblageContainer.topAnchor),
            assemblageButton.bottomAnchor.constraint(equalTo: assemblageContainer.bottomAnchor),
        ])
        contentStack.addArrangedSubview(assemblageContainer)

        // Price + Next in a horizontal row
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.distribution = .equalSpacing
        bottomRow.translatesAutoresizingMaskIntoConstraints = false
        bottomRow.addArrangedSubview(totalPriceLabel)
        bottomRow.addArrangedSubview(nextButton)
        contentStack.addArrangedSubview(bottomRow)
    }

    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = viewModel.product.name
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.poppins(.bold, size: 16),
            .foregroundColor: UIColor.mcPrimary,
        ]
    }

    private func populate() {
        nameLabel.text = viewModel.product.name

        let assetName = (viewModel.product.imagePath ?? "").components(separatedBy: "/").last ?? ""
        productImageView.image = UIImage(named: assetName) ?? UIImage(systemName: "cup.and.saucer.fill")
        productImageView.tintColor = .mcAccent

        updatePriceLabel(viewModel.totalPrice)
    }

    private func bindViewModel() {
        viewModel.$totalPrice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] price in
                self?.updatePriceLabel(price)
            }
            .store(in: &cancellables)
    }

    private func setupActions() {
        sizeSegment.addTarget(self, action: #selector(sizeTapped), for: .valueChanged)
        serviceSegment.addTarget(self, action: #selector(serviceTapped), for: .valueChanged)
        timeSegment.addTarget(self, action: #selector(timeTapped), for: .valueChanged)
        assemblageButton.addTarget(self, action: #selector(assemblageTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    }

    // MARK: - Helpers

    private func updatePriceLabel(_ price: Decimal) {
        let value = NSDecimalNumber(decimal: price).doubleValue
        totalPriceLabel.text = String(format: "£%.2f", value)
    }

    private static func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .poppins(.bold, size: 15)
        label.textColor = .mcPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    // MARK: - Actions

    @objc private func sizeTapped(_ sender: UISegmentedControl) {
        viewModel.selectedSize = CoffeeSize.allCases[sender.selectedSegmentIndex]
    }

    @objc private func serviceTapped(_ sender: UISegmentedControl) {
        viewModel.selectedServiceType = ServiceType.allCases[sender.selectedSegmentIndex]
    }

    @objc private func timeTapped(_ sender: UISegmentedControl) {
        viewModel.selectedTimeChoice = TimeChoice.allCases[sender.selectedSegmentIndex]
    }

    @objc private func assemblageTapped() {
        viewModel.startAssemblage()
    }

    @objc private func nextTapped() {
        viewModel.proceedToNext()
    }
}
