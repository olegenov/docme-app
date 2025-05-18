import Foundation
import SwiftData


protocol FolderStorageRepository {
    func fetch() async throws -> [Folder]
    func fetch(by uuid: UUID) async throws -> Folder?
    func insertOrUpdate(_ folder: Folder) async throws
    func update(_ folder: Folder) async throws
    func delete(_ folder: Folder) async throws
    func create(_ entiry: Folder) async throws
    func getSubfolders(of folder: Folder) async throws -> [Folder]
    func countDocuments(in folder: Folder) async throws -> Int
}


final class FolderStorageRepositoryImpl: FolderStorageRepository {
    private let service: StorageServiceImpl<Folder>
    private let documentSerice: StorageServiceImpl<Document>
    
    init(context: ModelContext) {
        self.service = StorageServiceImpl<Folder>(context: context)
        self.documentSerice = StorageServiceImpl<Document>(context: context)
    }

    func fetch() async throws -> [Folder] {
        try await service.fetchAll()
    }

    func insertOrUpdate(_ entity: Folder) async throws {
        if let existing = try await fetch(by: entity.uuid) {
            if existing.updatedAt < entity.updatedAt {
                existing.name = entity.name
                existing.updatedAt = entity.updatedAt
                existing.createdAt = entity.createdAt
                existing.parentFolder = entity.parentFolder
                existing.isDirty = entity.isDirty
                existing.lastSyncedAt = entity.lastSyncedAt
                existing.deleted = entity.deleted

                try await update(existing)
            }
        } else {
            try await create(entity)
        }
    }
    
    func fetch(by uuid: UUID) async throws -> Folder? {
        try await service.fetch(by: uuid)
    }
    
    func delete(_ entity: Folder) async throws {
        try await service.delete(entity)
    }

    func update(_ entity: Folder) async throws {
        try await service.update(entity)
    }
    
    func create(_ entiry: Folder) async throws {
        try await service.insert(entiry)
    }
    
    func getSubfolders(of folder: Folder) async throws -> [Folder] {
        let folderUUID: UUID? = folder.uuid
        
        let descriptor = FetchDescriptor<Folder>(
            predicate: #Predicate { folder in
                folder.parentFolder?.uuid == folderUUID
            }
        )
        
        return try await service.fetch(descriptor: descriptor)
    }
    
    func countDocuments(in folder: Folder) async throws -> Int {
        let targetUUID: UUID? = folder.uuid
        
        let descriptor = FetchDescriptor<Document>(
            predicate: #Predicate { $0.folder?.uuid == targetUUID }
        )
        
        return try await documentSerice.fetchCount(descriptor: descriptor)
    }
}
