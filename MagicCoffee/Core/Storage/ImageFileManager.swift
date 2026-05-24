import UIKit

final class ImageFileManager {
    static let shared = ImageFileManager()
    private init() {}

    private var baseURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MagicCoffeeImages", isDirectory: true)
    }

    func imageURL(for relativePath: String) -> URL {
        baseURL.appendingPathComponent(relativePath)
    }

    func saveImage(_ image: UIImage, relativePath: String) throws {
        let url = imageURL(for: relativePath)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        guard let data = image.pngData() else { throw ImageError.encodingFailed }
        try data.write(to: url)
    }

    func loadImage(relativePath: String) -> UIImage? {
        let url = imageURL(for: relativePath)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    enum ImageError: Error { case encodingFailed }
}
