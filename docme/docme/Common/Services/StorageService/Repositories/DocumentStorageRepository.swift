import Foundation
import SwiftData


protocol DocumentStorageRepository {
    func fetch() async throws -> [Document]
    func insertOrUpdate(_ netDoc: Document) async throws
    func update(_ doc: Document) async throws
    func delete(_ doc: Document) async throws
    func create(_ entiry: Document) async throws
    func getDocuments(of folder: Folder) async throws -> [Document]
}


final class DocumentStorageRepositoryImpl: DocumentStorageRepository {
    private let service: StorageServiceImpl<Document>

    init(context: ModelContext) {
        self.service = StorageServiceImpl(context: context)
    }

    func fetch() async throws -> [Document] {
        try await service.fetchAll()
    }
    
    func insertOrUpdate(_ netDoc: Document) async throws {
        if let existing = try await fetch(by: netDoc.uuid) {
            existing.title = netDoc.title
            existing.icon = netDoc.icon
            existing.color = netDoc.color
            existing.documentDescription = netDoc.documentDescription
            existing.isFavorite = netDoc.isFavorite
            existing.createdAt = netDoc.createdAt
            existing.updatedAt = netDoc.updatedAt
            existing.folder = netDoc.folder
            existing.isSynced = true
            existing.deleted = false
            
            try await update(existing)
        } else {
            let newDoc = Document(
                id: netDoc.uuid,
                title: netDoc.title,
                icon: netDoc.icon,
                color: netDoc.color,
                description: netDoc.documentDescription,
                isFavorite: netDoc.isFavorite,
                createdAt: netDoc.createdAt,
                updatedAt: netDoc.updatedAt,
                isSynced: true,
                folder: netDoc.folder,
                deleted: false
            )
            
            try await create(newDoc)
        }
    }
    
    func fetch(by uuid: UUID) async throws -> Document? {
        try await service.fetch(by: uuid)
    }

    func delete(_ entity: Document) async throws {
        try await service.delete(entity)
    }

    func update(_ entity: Document) async throws {
        try await service.update(entity)
    }
    
    func create(_ entiry: Document) async throws {
        try await service.insert(entiry)
    }
    
    func getDocuments(of folder: Folder) async throws -> [Document] {
        let folderUUID: UUID? = folder.uuid
        
        let descriptor = FetchDescriptor<Document>(
            predicate: #Predicate {
                $0.folder?.uuid == folderUUID
            }
        )
        
        return try await service.fetch(descriptor: descriptor)
    }
}
