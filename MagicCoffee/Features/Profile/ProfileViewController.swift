import Combine
import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: ProfileViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
        iv.image = UIImage(systemName: "person.crop.circle", withConfiguration: config)
        iv.tintColor = .mcPrimary
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Save"
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
        b.accessibilityIdentifier = "profile_save_button"
        return b
    }()

    // MARK: - Row data

    private struct RowInfo {
        let label: String
        let placeholder: String
        let accessibilityID: String
        let keyPath: WritableKeyPath<ProfileViewModel, String>
        let keyboardType: UIKeyboardType
    }

    private let rows: [RowInfo] = [
        RowInfo(label: "Name",    placeholder: "Enter name",    accessibilityID: "profile_name_field",    keyPath: \.name,    keyboardType: .default),
        RowInfo(label: "Phone",   placeholder: "Enter phone",   accessibilityID: "profile_phone_field",   keyPath: \.phone,   keyboardType: .phonePad),
        RowInfo(label: "Email",   placeholder: "Enter email",   accessibilityID: "profile_email_field",   keyPath: \.email,   keyboardType: .emailAddress),
        RowInfo(label: "Address", placeholder: "Enter address", accessibilityID: "profile_address_field", keyPath: \.address, keyboardType: .default),
    ]

    // MARK: - Init

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        bindViewModel()
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        viewModel.loadUser()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "Profile"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.poppins(.bold, size: 18),
            .foregroundColor: UIColor.mcPrimary,
        ]
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backgroundColor = .mcSurface
    }

    private func setupUI() {
        view.backgroundColor = .mcCardBg

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(avatarImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(saveButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),

            stackView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 28),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            saveButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 32),
            saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
        ])

        for (index, row) in rows.enumerated() {
            let rowView = makeRowView(row: row, index: index)
            stackView.addArrangedSubview(rowView)

            // Separator (not after last row)
            if index < rows.count - 1 {
                let separator = UIView()
                separator.backgroundColor = UIColor.mcPrimary.withAlphaComponent(0.1)
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
                stackView.addArrangedSubview(separator)
            }
        }
    }

    private func makeRowView(row: RowInfo, index: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .mcSurface
        container.translatesAutoresizingMaskIntoConstraints = false

        let labelView = UILabel()
        labelView.text = row.label
        labelView.font = .poppins(.medium, size: 14)
        labelView.textColor = .mcPrimary
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.setContentHuggingPriority(.required, for: .horizontal)

        let textField = UITextField()
        textField.placeholder = row.placeholder
        textField.font = .poppins(.regular, size: 14)
        textField.textColor = .mcPrimary
        textField.textAlignment = .right
        textField.keyboardType = row.keyboardType
        textField.autocapitalizationType = row.keyboardType == .default ? .words : .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.accessibilityIdentifier = row.accessibilityID
        textField.tag = index

        let pencilImage = UIImage(systemName: "pencil")?
            .withTintColor(UIColor.mcPrimary.withAlphaComponent(0.5), renderingMode: .alwaysOriginal)
        let pencilView = UIImageView(image: pencilImage)
        pencilView.contentMode = .scaleAspectFit
        pencilView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(labelView)
        container.addSubview(textField)
        container.addSubview(pencilView)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 56),

            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            labelView.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            pencilView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            pencilView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            pencilView.widthAnchor.constraint(equalToConstant: 18),
            pencilView.heightAnchor.constraint(equalToConstant: 18),

            textField.leadingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: pencilView.leadingAnchor, constant: -8),
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)

        return container
    }

    // MARK: - Bind

    private func bindViewModel() {
        // Name
        viewModel.$name
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.textField(withTag: 0)?.text = value
            }
            .store(in: &cancellables)

        // Phone
        viewModel.$phone
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.textField(withTag: 1)?.text = value
            }
            .store(in: &cancellables)

        // Email
        viewModel.$email
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.textField(withTag: 2)?.text = value
            }
            .store(in: &cancellables)

        // Address
        viewModel.$address
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.textField(withTag: 3)?.text = value
            }
            .store(in: &cancellables)
    }

    private func textField(withTag tag: Int) -> UITextField? {
        // Walk the stack to find the text field tagged by row index
        for arrangedView in stackView.arrangedSubviews {
            if let tf = arrangedView.viewWithTag(tag) as? UITextField {
                return tf
            }
        }
        return nil
    }

    // MARK: - Actions

    @objc private func textFieldChanged(_ sender: UITextField) {
        let value = sender.text ?? ""
        switch sender.tag {
        case 0: viewModel.name    = value
        case 1: viewModel.phone   = value
        case 2: viewModel.email   = value
        case 3: viewModel.address = value
        default: break
        }
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        viewModel.save()
        showSavedConfirmation()
    }

    private func showSavedConfirmation() {
        let alert = UIAlertController(title: "Saved", message: "Your profile has been updated.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
