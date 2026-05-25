import Combine
import UIKit

final class CatalogViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: CatalogViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .mcCardBg
        cv.showsVerticalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.accessibilityIdentifier = "catalog_collection_view"
        return cv
    }()

    // MARK: - Init

    init(viewModel: CatalogViewModel) {
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
        viewModel.loadProducts()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .mcCardBg
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseID)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backgroundColor = .mcSurface
        navigationController?.navigationBar.shadowImage = UIImage()

        // Title: greeting with user name
        let name = currentUserFirstName()
        title = "Welcome! \(name)"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.poppins(.bold, size: 18),
            .foregroundColor: UIColor.mcPrimary,
        ]

        // Right bar items
        let cartButton = UIBarButtonItem(
            image: UIImage(systemName: "cart"),
            style: .plain,
            target: nil,
            action: nil
        )
        cartButton.tintColor = .mcPrimary

        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: nil,
            action: nil
        )
        profileButton.tintColor = .mcPrimary

        navigationItem.rightBarButtonItems = [profileButton, cartButton]
    }

    private func currentUserFirstName() -> String {
        let stored = UserDefaults.standard.string(forKey: "mc_user_name") ?? ""
        let firstName = stored.split(separator: " ").first.map(String.init) ?? stored
        return firstName.isEmpty ? "Alex" : firstName
    }

    private func bindViewModel() {
        viewModel.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDataSource

extension CatalogViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.products.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCell.reuseID,
            for: indexPath
        ) as! ProductCell
        let product = viewModel.products[indexPath.item]
        cell.configure(with: product, index: indexPath.item)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        viewModel.selectProduct(viewModel.products[indexPath.item])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CatalogViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let insets: CGFloat = 16 * 2  // left + right section insets
        let spacing: CGFloat = 16      // inter-item spacing
        let availableWidth = collectionView.bounds.width - insets - spacing
        let cellWidth = floor(availableWidth / 2)
        return CGSize(width: cellWidth, height: cellWidth * 1.35)
    }
}

// MARK: - ProductCell

private final class ProductCell: UICollectionViewCell {
    static let reuseID = "ProductCell"

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .mcSurface
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 8
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = UIColor.mcCardBg
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.bold, size: 14)
        label.textColor = .mcTextPrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(.regular, size: 13)
        label.textColor = .mcAccent
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(productImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(priceLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            productImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            productImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            productImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor),

            nameLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            priceLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12),
        ])
    }

    func configure(with product: CDProduct, index: Int) {
        accessibilityIdentifier = "product_cell_\(index)"

        nameLabel.text = product.name

        let price = product.price?.doubleValue ?? 0
        let formatted = String(format: "£%.2f", price)
        priceLabel.text = formatted

        // Load image from assets using the last path component as the asset name
        let assetName = (product.imagePath ?? "").components(separatedBy: "/").last ?? ""
        productImageView.image = UIImage(named: assetName) ?? UIImage(systemName: "cup.and.saucer.fill")
        productImageView.tintColor = .mcAccent
    }
}
