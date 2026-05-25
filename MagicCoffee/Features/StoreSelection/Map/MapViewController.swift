import Combine
import MapKit
import UIKit

final class MapViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: MapViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    private let selectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Select Store", for: .normal)
        btn.titleLabel?.font = .poppins(.bold, size: 17)
        btn.setTitleColor(UIColor(hex: "#314B59"), for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 24
        btn.accessibilityIdentifier = "map_select_button"
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    init(viewModel: MapViewModel) {
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
        setupMap()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupUI() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        title = "Choose Location"

        view.addSubview(mapView)
        view.addSubview(selectButton)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            selectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            selectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            selectButton.heightAnchor.constraint(equalToConstant: 52),
        ])

        selectButton.addTarget(self, action: #selector(selectTapped), for: .touchUpInside)
    }

    private func setupMap() {
        // Center on Bradford UK
        let bradfordCenter = CLLocationCoordinate2D(latitude: 53.7960, longitude: -1.7594)
        let region = MKCoordinateRegion(
            center: bradfordCenter,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )
        mapView.setRegion(region, animated: false)
        mapView.delegate = self

        // Drop a pin for each store
        for store in viewModel.stores {
            let annotation = StoreAnnotation(store: store)
            mapView.addAnnotation(annotation)
        }

        // Pre-select the initial store's pin
        selectAnnotation(for: viewModel.selectedStore)
    }

    private func bindViewModel() {
        viewModel.$selectedStore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] store in
                self?.selectAnnotation(for: store)
            }
            .store(in: &cancellables)
    }

    private func selectAnnotation(for store: CDStore) {
        guard let annotation = mapView.annotations.first(where: {
            ($0 as? StoreAnnotation)?.store.id == store.id
        }) else { return }
        mapView.selectAnnotation(annotation, animated: true)
    }

    // MARK: - Actions

    @objc private func selectTapped() {
        viewModel.confirmSelection()
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        guard let storeAnnotation = annotation as? StoreAnnotation else { return }
        viewModel.selectStore(storeAnnotation.store)
    }
}

// MARK: - StoreAnnotation

private final class StoreAnnotation: NSObject, MKAnnotation {
    let store: CDStore

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
    }

    var title: String? { store.name }
    var subtitle: String? { store.address }

    init(store: CDStore) {
        self.store = store
        super.init()
    }
}
