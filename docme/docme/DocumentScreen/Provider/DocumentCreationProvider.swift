import Foundation
import SwiftUI


protocol DocumentScreenProvider {
    func createDocument(_ id: UUID, _ document: DocumentScreen) async -> Bool
    func saveDocument(with id: UUID, fields: [DocumentScreenField]) async -> Bool
    func fetchDocument(with id: UUID) async throws -> DocumentScreen
    func fetchFields(with id: UUID) async throws -> [DocumentScreenField]
    func deleteDocument(with id: UUID) async -> Bool
}

final class DocumentScreenProviderImpl: DocumentScreenProvider {
    enum Errors: Error {
        case documentNotFound
    }
    
    private let documentRepository: DocumentRepository
    private let fieldRepository: FieldRepository
    private let imageService: ImageService
    
    init(
        documentRepository: DocumentRepository,
        fieldRepository: FieldRepository,
        imageService: ImageService
    ) {
        self.documentRepository = documentRepository
        self.fieldRepository = fieldRepository
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
    
    func saveDocument(with id: UUID, fields: [DocumentScreenField]) async -> Bool {
        do {
            let document = try await documentRepository.getDocument(with: id)
            
            guard let document else { throw Errors.documentNotFound }
            
            try await documentRepository.saveLocal(document)
            try await fieldRepository.replaceFields(
                for: document,
                with: fields.filter {
                    !$0.isEmpty
                }.map {
                    .init(
                        id: $0.id,
                        name: $0.name,
                        value: $0.value,
                        document: document
                    )
                }
            )
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
    
    func fetchFields(with id: UUID) async throws -> [DocumentScreenField] {
        let document = try await documentRepository.getDocument(with: id)
        
        guard let document else { throw Errors.documentNotFound }
        
        return document.fields.map { field in
            .init(
                id: field.uuid,
                name: field.name,
                value: field.value
            )
        }
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
