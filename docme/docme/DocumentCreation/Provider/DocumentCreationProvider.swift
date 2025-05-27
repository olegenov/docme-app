import Foundation
import SwiftUI


protocol DocumentCreationProvider {
    func saveDocument(_ document: DocumentCreationModel) async -> Bool
}

final class DocumentCreationProviderImpl: DocumentCreationProvider {
    private let documentRepository: DocumentRepository
    private let imageService: ImageService
    
    init(
        documentRepository: DocumentRepository,
        imageService: ImageService
    ) {
        self.documentRepository = documentRepository
        self.imageService = imageService
    }
    
    func saveDocument(_ document: DocumentCreationModel) async -> Bool {
        do {
            let id = UUID()
            
            let imageUrl = try imageService.saveImage(
                document.image,
                id: id
            )
            
            try await documentRepository.createLocal(
                .init(
                    id: id,
                    title: document.title.isEmpty ? Captions.newDocument : document.title,
                    imagePath: imageUrl,
                    remoteImageURL: nil,
                    icon: document.type,
                    color: document.color
                )
            )
            
            return true
        } catch {
            return false
        }
    }
}
