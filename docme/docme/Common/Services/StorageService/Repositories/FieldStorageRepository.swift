import Foundation
import SwiftData


protocol FieldStorageRepository {
    func fetch(by uuid: UUID) async throws -> DocumentField?
    func delete(_ doc: DocumentField) async throws
    func create(_ entiry: DocumentField) async throws
}


final class FieldStorageRepositoryImpl: FieldStorageRepository {
    private let service: StorageServiceImpl<DocumentField>

    init(context: ModelContext) {
        self.service = StorageServiceImpl(context: context)
    }

    func fetch(by uuid: UUID) async throws -> DocumentField? {
        try await service.fetch(by: uuid)
    }

    func delete(_ entity: DocumentField) async throws {
        try await service.delete(entity)
    }
    
    func create(_ entiry: DocumentField) async throws {
        try await service.insert(entiry)
    }
}
