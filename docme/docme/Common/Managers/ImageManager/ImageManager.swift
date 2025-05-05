import Foundation
import UIKit

protocol ImageManager {
    func loadImage(from url: String) async -> UIImage
}
