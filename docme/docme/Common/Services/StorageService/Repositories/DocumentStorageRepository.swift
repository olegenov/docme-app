import Foundation
import SwiftData


protocol DocumentStorageRepository {
    func fetch() async throws -> [Document]
    func update(_ doc: Document) async throws
    func delete(_ doc: Document) async throws
    func create(_ entiry: Document) async throws
    func getDocuments(of folder: Folder?) async throws -> [Document]
}


final class DocumentStorageRepositoryImpl: DocumentStorageRepository {
    private let service: StorageServiceImpl<Document>

    init(context: ModelContext) {
        self.service = StorageServiceImpl(context: context)
    }

    func fetch() async throws -> [Document] {
        try await service.fetchAll()
    }
    
    func fetch(by uuid: UUID) async throws -> Document? {
        try await service.fetch(by: uuid)
    }

    func delete(_ entity: Document) async throws {
        try await service.delete(entity)
    }

    func update(_ entity: Document) async throws {
        entity.updatedAt = Date()
        
        try await service.update(entity)
    }
    
    func create(_ entiry: Document) async throws {
        try await service.insert(entiry)
    }
    
    func getDocuments(of folder: Folder?) async throws -> [Document] {
        let folderUUID: UUID? = folder?.uuid
        
        let descriptor = FetchDescriptor<Document>(
            predicate: #Predicate {
                $0.folder?.uuid == folderUUID
            }
        )
        
        return try await service.fetch(descriptor: descriptor)
    }
}
