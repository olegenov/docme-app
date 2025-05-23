import Foundation


protocol FolderRepository {
    func sync() async throws
    func fetchLocal() async throws -> [Folder]
    func createLocal(_ folder: Folder) async throws
    func getLocal(with id: UUID) async throws -> Folder?
    func deleteLocal(with id: UUID) async throws
    
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

        try await syncDirtyFolders(dirtyFolders, remoteFolders)
        try await updateLocalFolders(localFolders, remoteFolders)
        try await syncLocalDeletions(localFolders, remoteFolders)
    }

    func fetchLocal() async throws -> [Folder] {
        try await storage.fetch()
    }

    func getLocal(with id: UUID) async throws -> Folder? {
        try await storage.fetch(by: id)
    }

    func createLocal(_ folder: Folder) async throws {
        try await storage.create(folder)
    }
    
    func deleteLocal(with id: UUID) async throws {
        let folder = try await getLocal(with: id)
        
        if let folder {
            try await storage.delete(folder)
        }
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
                do {
                    try await api.delete(uuid: folder.uuid)
                } catch {
                    print("Failed to delete folder \(folder.uuid) from API: \(error)")
                    continue
                }
                try await storage.delete(folder)
                continue
            }

            if remoteUUIDs.contains(folder.uuid) {
                try await api.update(folder.toNetworkModel())
            } else {
                try await api.create(folder.toNetworkModel())
            }

            folder.isDirty = false
            folder.updatedAt = .now

            try await storage.update(folder)
        }
    }

    func updateLocalFolders(
        _ localFolders: [Folder],
        _ remoteFolders: [FolderNetworking]
    ) async throws {
        let localMap = Dictionary(uniqueKeysWithValues: localFolders.map { ($0.uuid, $0) })

        for remote in remoteFolders {
            guard let local = localMap[remote.uuid] else {
                try await insertNewFolder(from: remote)
                continue
            }

            if remote.updatedAt > local.updatedAt {
                try await updateLocalFolder(local, with: remote)
            }
        }
    }

    func syncLocalDeletions(
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

    func insertNewFolder(from remote: FolderNetworking) async throws {
        let folder = Folder(
            id: remote.uuid,
            name: remote.name,
            createdAt: remote.createdAt,
            updatedAt: remote.updatedAt,
            parentFolder: await getParentFolder(of: remote),
            isDirty: false,
            deleted: false
        )

        try await storage.create(folder)
    }

    func updateLocalFolder(_ local: Folder, with remote: FolderNetworking) async throws {
        local.name = remote.name
        local.updatedAt = remote.updatedAt
        local.parentFolder = await getParentFolder(of: remote)
        local.isDirty = false

        try await storage.update(local)
    }
    
    func getParentFolder(of remote: FolderNetworking) async -> Folder? {
        var parent: Folder? = nil
        
        if let parentId = remote.parentFolderId {
            parent = try? await storage.fetch(
                by: parentId
            )
        }
        
        return parent
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
