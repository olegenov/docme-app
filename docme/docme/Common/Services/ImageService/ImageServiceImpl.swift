import Foundation
import UIKit


final class ImageServiceImpl: ImageService {
    func downloadImage(from url: URL, id: UUID) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        let fileName = "\(id).png"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        try data.write(to: fileURL)
        return fileName
    }

    func loadImage(from path: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(path)
        return UIImage(contentsOfFile: fileURL.path)
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
