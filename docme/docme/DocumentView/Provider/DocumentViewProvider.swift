import Foundation
import SwiftUI


protocol DocumentViewProvider {
    func fetchDocument(with id: UUID) async throws -> DocumentModel
    func fetchFields(with id: UUID) async -> [DocumentField]
}

final class DocumentViewProviderImpl: DocumentViewProvider {
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
    
    func fetchDocument(with id: UUID) async throws -> DocumentModel {
        do {
            let document = try await documentRepository.getDocument(with: id)
            
            guard let document else { throw Errors.documentNotFound }
            var image: UIImage? = nil
            
            if let imagePath = document.imagePath {
                image = imageService.loadImage(from: imagePath)
            }
            
            return .init(
                title: document.title,
                description: document.documentDescription == "" ? nil : document.documentDescription,
                image: image,
                type: document.icon.toModelIcon(),
                color: document.color.toModelColor()
            )
        }
    }
    
    func fetchFields(with id: UUID) async -> [DocumentField] {
        return [
            .init(id: .init(), name: "123", value: "1234"),
            .init(id: .init(), name: "1235", value: "1235")
        ]
    }
}
