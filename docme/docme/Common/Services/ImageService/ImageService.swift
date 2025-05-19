import Foundation
import UIKit


protocol ImageService {
    func downloadImage(from url: URL, id: UUID) async throws -> String
    func loadImage(from path: String) -> UIImage?
}
