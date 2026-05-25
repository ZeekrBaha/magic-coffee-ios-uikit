import CoreImage
import Foundation
import UIKit

final class ConfirmationViewModel {
    let order: CDOrder
    let state: AssemblageState

    var orderIDText: String {
        order.id?.uuidString ?? "—"
    }

    var storeNameText: String {
        order.store?.name ?? state.selectedStoreName ?? "Magic Coffee"
    }

    var estimatedTimeText: String {
        "~15 minutes"
    }

    var pickupCodeText: String {
        order.pickupCode ?? orderIDText.prefix(6).uppercased().description
    }

    init(order: CDOrder, state: AssemblageState) {
        self.order = order
        self.state = state
    }

    /// Generates a QR code image from the order ID string.
    func generateQRImage(size: CGSize) -> UIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let data = orderIDText.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }
        let scaleX = size.width / outputImage.extent.width
        let scaleY = size.height / outputImage.extent.height
        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
