import Foundation
import UIKit


final class ImageServiceImpl: ImageService {
    enum ImageServiceError: Error {
        case imageConversionFailed
    }
    
    func downloadImage(from url: URL, id: UUID) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        let fileName = getFileName(id: id)
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        try data.write(to: fileURL)
        return fileName
    }

    func loadImage(from path: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(path)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func saveImage(_ image: UIImage, id: UUID) throws -> String {
        let fileName = getFileName(id: id)
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        guard let pngData = image.pngData() else {
            AppLogger.shared.error("Error loading pngData")
            throw ImageServiceError.imageConversionFailed
        }
        
        try pngData.write(to: fileURL)
        
        return fileName
    }
}

private extension ImageServiceImpl {
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func getFileName(id: UUID) -> String {
        "\(id).png"
    }
}
