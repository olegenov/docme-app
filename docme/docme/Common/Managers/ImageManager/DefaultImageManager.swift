import SwiftUI


class DefaultImageManager: ImageManager, ObservableObject {
    static let shared = DefaultImageManager()
    
    private var imageCache = NSCache<NSString, UIImage>()
    
    private init() { }
    
    func loadImage(from url: String) async -> UIImage {
        if let cachedImage = imageCache.object(forKey: url as NSString) {
            return cachedImage
        }
        
        guard let imageURL = URL(string: url) else {
            return UIImage()
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            if let loadedImage = UIImage(data: data) {
                imageCache.setObject(loadedImage, forKey: url as NSString)
                return loadedImage
            }
        } catch {
            print("Ошибка загрузки изображения: \(error.localizedDescription)")
        }
        
        return UIImage()
    }
}


