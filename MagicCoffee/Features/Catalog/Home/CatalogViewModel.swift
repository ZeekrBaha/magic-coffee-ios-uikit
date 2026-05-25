import Combine
import Foundation

final class CatalogViewModel: BaseViewModel {
    @Published var products: [CDProduct] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let productService: ProductService

    init(productService: ProductService = .shared) {
        self.productService = productService
    }

    func loadProducts() {
        Task { @MainActor in
            isLoading = true
            defer { isLoading = false }
            do {
                products = try await productService.fetchAll()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func selectProduct(_ product: CDProduct) {
        (coordinator as? CatalogCoordinator)?.showProductDetail(product: product)
    }
}
