import Foundation
import SwiftUI


protocol DocumentCreationProvider {
    func saveDocument(_ document: DocumentCreationModel) async -> UUID?
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
    
    func saveDocument(_ document: DocumentCreationModel) async -> UUID? {
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
                    color: document.color,
                    description: document.description
                )
            )
            
            return id
        } catch {
            return nil
        }
    }
}
