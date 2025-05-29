import Foundation


protocol FolderRepository {
    func syncFolders() async
    func fetchLocal() async throws -> [Folder]
    func createLocal(_ folder: Folder) async throws
    func getLocal(with id: UUID) async throws -> Folder?
    func deleteLocal(with id: UUID) async throws
    
    func getSubFolders(of folder: Folder?) async throws -> [Folder]
    func countDocuments(of folder: Folder) async throws -> Int
}


actor FolderRepositoryImpl: FolderRepository {
    private let storage: FolderStorageRepository
    private let api: FolderNetworkingRepository

    init(
        storage: FolderStorageRepository,
        api: FolderNetworkingRepository
    ) {
        self.storage = storage
        self.api = api
    }
    
    func syncFolders() async {
        do {
            try await sendLocalChanges()
            
            try await getUpdates()
        } catch {
            AppLogger.shared.error("Error during folder sync: \(error)")
        }
    }

    func fetchLocal() async throws -> [Folder] {
        try await storage.fetch().filter { !$0.deleted }
    }

    func getLocal(with id: UUID) async throws -> Folder? {
        try await storage.fetch(by: id)
    }

    func createLocal(_ folder: Folder) async throws {
        folder.isNew = true
        try await storage.create(folder)
    }
    
    func deleteLocal(with id: UUID) async throws {
        let folder = try await getLocal(with: id)
        
        if let folder {
            try await storage.delete(folder)
        }
    }
    
    func getSubFolders(of folder: Folder?) async throws -> [Folder] {
        try await storage.getSubfolders(of: folder).filter { !$0.deleted }
    }
    
    func countDocuments(of folder: Folder) async throws -> Int {
        try await storage.countDocuments(in: folder)
    }
}

private extension FolderRepositoryImpl {
    func sendLocalChanges() async throws {
        let localFolders = try await storage.fetch()
        
        for folder in localFolders {
            if folder.deleted {
                await api.delete(folder: folder.toNetworkingModel()) { _ in }
                try await storage.delete(folder)
                continue
            }
            
            if folder.isNew {
                await api.create(folder: folder.toNetworkingModel()) { _ in }
                folder.isNew = false
                folder.isDirty = false
                try await storage.update(folder)
                continue
            }
            
            if folder.isDirty {
                await api.update(folder: folder.toNetworkingModel()) { _ in }
                folder.isDirty = false
                try await storage.update(folder)
            }
        }
    }
    
    func getUpdates() async throws {
        await api.fetchChanges { [weak self] result in
            guard let self else { return }
            
            Task { [weak self] in
                guard let self else { return }
                
                switch result {
                case .success(let remoteFolders):
                    for remote in remoteFolders {
                        if remote.deleted {
                            if let local = try await storage.fetch(by: remote.uuid) {
                                try await storage.delete(local)
                            }
                            continue
                        }
                        
                        var parent: Folder? = nil
                        if let parentUUID = remote.parentFolderUUID {
                            parent = try await storage.fetch(by: parentUUID)
                        }
                        
                        if let local = try await storage.fetch(by: remote.uuid) {
                            local.name = remote.name
                            local.updatedAt = remote.updatedAt
                            local.parentFolder = parent
                            local.deleted = false
                            local.isDirty = false
                            try await storage.update(local)
                        } else {
                            let newFolder = remote.toLocalModel(parent: parent)
                            try await storage.create(newFolder)
                        }
                    }
                    
                case .failure(let error):
                    print("Failed to sync folders: \(error)")
                }
            }
        }
    }
}
