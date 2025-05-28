import Foundation


protocol FieldRepository {
    func replaceFields(for document: Document, with newFields: [DocumentField]) async throws
}

actor FieldRepositoryImpl: FieldRepository {
    private let storage: FieldStorageRepository
    
    init(storage: FieldStorageRepository) {
        self.storage = storage
    }

    func replaceFields(for document: Document, with newFields: [DocumentField]) async throws {
        for field in document.fields {
            try await storage.delete(field)
        }

        for field in newFields {
            field.document = document
            try await storage.create(field)
        }

        document.fields = newFields
    }
}
