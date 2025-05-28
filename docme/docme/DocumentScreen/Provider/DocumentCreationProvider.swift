import Foundation
import SwiftUI


protocol DocumentScreenProvider {
    func createDocument(_ id: UUID, _ document: DocumentScreen) async -> Bool
    func saveDocument(with id: UUID) async -> Bool
    func fetchDocument(with id: UUID) async throws -> DocumentScreen
    func fetchFields(with id: UUID) async -> [DocumentScreenField]
    func deleteDocument(with id: UUID) async -> Bool
}

final class DocumentScreenProviderImpl: DocumentScreenProvider {
    enum Errors: Error {
        case documentNotFound
    }
    
    private let documentRepository: DocumentRepository
    private let imageService: ImageService
    
    init(
        documentRepository: DocumentRepository,
        imageService: ImageService
    ) {
        self.documentRepository = documentRepository
        self.imageService = imageService
    }
    
    func createDocument(
        _ id: UUID,
        _ document: DocumentScreen
    ) async -> Bool {
        do {
            guard let image = document.image else {
                return false
            }
            
            let imageUrl = try imageService.saveImage(
                image,
                id: id
            )
            
            try await documentRepository.createLocal(
                .init(
                    id: id,
                    title: document.title.isEmpty ? Captions.newDocument : document.title,
                    imagePath: imageUrl,
                    remoteImageURL: nil,
                    icon: document.icon.toDomain(),
                    color: document.color.toDomain(),
                    description: document.description
                )
            )
            
            return true
        } catch {
            return false
        }
    }
    
    func saveDocument(with id: UUID) async -> Bool {
        do {
            let document = try await documentRepository.getDocument(with: id)
            
            guard let document else { throw Errors.documentNotFound }
            
            try await documentRepository.saveLocal(document)
            
            return true
        } catch {
            AppLogger.shared.error("Error saving document: \(error)")
            return false
        }
    }
    
    func fetchDocument(with id: UUID) async throws -> DocumentScreen {
        let document = try await documentRepository.getDocument(with: id)
        
        guard let document else { throw Errors.documentNotFound }
        var image: UIImage? = nil
        
        if let imagePath = document.imagePath {
            image = imageService.loadImage(from: imagePath)
        }
        
        return .init(
            title: document.title,
            description: document.documentDescription ?? "",
            image: image,
            icon: document.icon.toModelIcon(),
            color: document.color.toModelColor()
        )
    }
    
    func fetchFields(with id: UUID) async -> [DocumentScreenField] {
        return [
            .init(id: .init(), name: "123", value: "1234"),
            .init(id: .init(), name: "1235", value: "1235")
        ]
    }
    
    func deleteDocument(with id: UUID) async -> Bool {
        do {
            let document = try await documentRepository.getDocument(with: id)
            
            guard let document else { throw Errors.documentNotFound }
            
            try await documentRepository.deleteDocument(document)
            
            return true
        } catch {
            AppLogger.shared.error("Error deleting document: \(error)")
            return false
        }
    }
}
