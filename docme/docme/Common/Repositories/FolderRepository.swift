import Foundation


protocol FolderRepository {
    func sync() async throws
    func fetchLocal() async throws -> [Folder]
    func getLocal(with uuid: UUID?) async throws -> Folder?
    func createLocal(_ folder: Folder) async throws
    
    func getSubFolders(of folder: Folder) async throws -> [Folder]
    func countDocuments(of folder: Folder) async throws -> Int
}


final class FolderRepositoryImpl: FolderRepository {
    private let storage: FolderStorageRepository
    private let api: FolderNetworkingRepository

    init(
        storage: FolderStorageRepository,
        api: FolderNetworkingRepository
    ) {
        self.storage = storage
        self.api = api
    }
    
    func sync() async throws {
        let remoteFolders = try await api.fetchAll()
        let localFolders = try await storage.fetch()

        let dirtyFolders = localFolders.filter { $0.isDirty }

        try await syncDirtyFolders(
            dirtyFolders,
            remoteFolders
         )

        try await updateLocal(
            localFolders,
            remoteFolders
        )

        try await deleteRemoteFolders(
            localFolders,
            remoteFolders
        )
    }

    func fetchLocal() async throws -> [Folder] {
        try await storage.fetch()
    }
    
    func getLocal(with uuid: UUID?) async throws -> Folder? {
        guard let uuid else { return nil }
        
        return try await storage.fetch(by: uuid)
    }

    func createLocal(_ folder: Folder) async throws {
        try await storage.create(folder)
    }
    
    func getSubFolders(of folder: Folder) async throws -> [Folder] {
        try await storage.getSubfolders(of: folder)
    }
    
    func countDocuments(of folder: Folder) async throws -> Int {
        try await storage.countDocuments(in: folder)
    }
}

private extension FolderRepositoryImpl {
    func syncDirtyFolders(
        _ dirtyFolders: [Folder],
        _ remoteFolders: [FolderNetworking]
    ) async throws {
        let remoteUUIDs = Set(remoteFolders.map { $0.uuid })
        
        for folder in dirtyFolders {
            if folder.deleted {
                try await api.delete(uuid: folder.uuid)
                try await storage.delete(folder)
                
                return
            }
            
            if remoteUUIDs.contains(folder.uuid) {
                try await api.update(folder.toNetworkModel())
                
                folder.isDirty = false
                folder.lastSyncedAt = Date()
                
                try await storage.insertOrUpdate(folder)
                
                return
            }
            
            try await api.create(folder.toNetworkModel())
            
            folder.isDirty = false
            folder.lastSyncedAt = Date()
            
            try await storage.insertOrUpdate(folder)
        }
    }
    
    func updateLocal(
        _ localFolders: [Folder],
        _ remoteFolders: [FolderNetworking]
    ) async throws {
        let localMap = Dictionary(
            uniqueKeysWithValues: localFolders.map {
                ($0.uuid, $0)
            }
        )
        
        for remote in remoteFolders {
            guard let local = localMap[remote.uuid] else {
                let parentFolder = remote.parentFolderId.flatMap { localMap[$0] }
                let newFolder = Folder(
                    id: remote.uuid,
                    name: remote.name,
                    createdAt: remote.createdAt,
                    updatedAt: remote.updatedAt,
                    parentFolder: parentFolder,
                    isDirty: false,
                    lastSyncedAt: Date(),
                    deleted: false
                )
                try await storage.insertOrUpdate(newFolder)
                
                continue
            }

            if !local.isDirty {
                local.name = remote.name
                local.updatedAt = remote.updatedAt
                local.createdAt = remote.createdAt
                local.parentFolder = remote.parentFolderId.flatMap { localMap[$0] }
                local.lastSyncedAt = Date()
                try await storage.insertOrUpdate(local)
            }
        }
    }
    
    func deleteRemoteFolders(
        _ localFolders: [Folder],
        _ remoteFolders: [FolderNetworking]
    ) async throws {
        let remoteUUIDs = Set(remoteFolders.map { $0.uuid })
        
        for local in localFolders {
            if !remoteUUIDs.contains(local.uuid), !local.isDirty {
                try await storage.delete(local)
            }
        }
    }
}


private extension Folder {
    func toNetworkModel() -> FolderNetworking {
        .init(
            id: uuid,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            parentFolderId: parentFolder?.uuid
        )
    }
}
