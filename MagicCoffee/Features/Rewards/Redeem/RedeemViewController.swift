import Combine
import UIKit

final class RedeemViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: RedeemViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(RedeemProductCell.self, forCellWithReuseIdentifier: RedeemProductCell.reuseID)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.accessibilityIdentifier = "redeem_collection_view"
        return cv
    }()

    // MARK: - Init

    init(viewModel: RedeemViewModel) {
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

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "Redeem"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.poppins(.bold, size: 18),
            .foregroundColor: UIColor.mcPrimary,
        ]
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setupUI() {
        view.backgroundColor = .mcCardBg
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Bind

    private func bindViewModel() {
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: &cancellables)

        viewModel.$didRedeem
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDataSource

extension RedeemViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RedeemProductCell.reuseID,
            for: indexPath
            // swiftlint:disable:next force_cast
        ) as! RedeemProductCell
        let product = viewModel.products[indexPath.item]
        cell.configure(with: product, index: indexPath.item)
        cell.onRedeem = { [weak self] in
            self?.viewModel.redeem(product: product)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RedeemViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: 150)
    }
}

// MARK: - RedeemProductCell

final class RedeemProductCell: UICollectionViewCell {
    static let reuseID = "RedeemProductCell"

    var onRedeem: (() -> Void)?

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .mcSurface
        v.layer.cornerRadius = 14
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.07
        v.layer.shadowRadius = 6
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .mcAccent
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .poppins(.bold, size: 16)
        l.textColor = .mcPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let costLabel: UILabel = {
        let l = UILabel()
        l.font = .poppins(.regular, size: 14)
        l.textColor = .mcPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let redeemButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Redeem"
        config.baseBackgroundColor = .mcAccent
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFont.poppins(.medium, size: 14)
            return out
        }
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
        let b = UIButton(configuration: config)
        b.layer.cornerRadius = 10
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.addSubview(cardView)
        [iconView, nameLabel, costLabel, redeemButton].forEach { cardView.addSubview($0) }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            iconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),

            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),

            costLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            costLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),

            redeemButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            redeemButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
        ])

        redeemButton.addTarget(self, action: #selector(redeemTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    func configure(with product: RedeemProduct, index: Int) {
        iconView.image = UIImage(systemName: product.symbolName)
        nameLabel.text = product.name
        costLabel.text = "\(product.cost) points"
        redeemButton.accessibilityIdentifier = "redeem_card_\(index)"
    }

    @objc private func redeemTapped() {
        onRedeem?()
    }
}
