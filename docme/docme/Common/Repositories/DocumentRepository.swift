import Foundation


protocol DocumentRepository {
    func sync() async throws
    func fetchLocal() async throws -> [Document]
    func createLocal(_ document: Document) async throws
    func getDocuments(of folder: Folder?) async throws -> [Document]
}

actor DocumentRepositoryImpl: DocumentRepository {
    private let storage: DocumentStorageRepository
    private let api: DocumentNetworkingRepository
    private let folderRepository: FolderRepository
    private let imageService: ImageService
    
    init(
        storage: DocumentStorageRepository,
        api: DocumentNetworkingRepository,
        folderRepository: FolderRepository,
        imageService: ImageService
    ) {
        self.storage = storage
        self.api = api
        self.folderRepository = folderRepository
        self.imageService = imageService
    }

    func sync() async throws {
        let remoteDocuments = try await api.fetchAll()
        let localDocuments = try await storage.fetch()

        let dirtyDocuments = localDocuments.filter {
            $0.isDirty
        }

        try await syncDirtyDocuments(
            dirtyDocuments,
            remoteDocuments
        )

        try await updateLocalDocuments(
            localDocuments,
            remoteDocuments
        )

        try await cleanupLocallyDeleted(
            localDocuments,
            remoteDocuments
        )
    }

    func fetchLocal() async throws -> [Document] {
        try await storage.fetch()
    }
    
    func createLocal(_ document: Document) async throws {
        try await storage.create(document)
    }
    
    func getDocuments(of folder: Folder?) async throws -> [Document] {
        try await storage.getDocuments(of: folder)
    }
}

private extension DocumentRepositoryImpl {
    func syncDirtyDocuments(
        _ dirtyDocuments: [Document],
        _ remoteDocuments: [DocumentNetworking]
    ) async throws {
        let remoteUUIDs = Set(remoteDocuments.map { $0.uuid })

        for document in dirtyDocuments {
            if document.deleted {
                do {
                    try await api.delete(uuid: document.uuid)
                } catch { continue }
                
                try await storage.delete(document)
                continue
            }

            if remoteUUIDs.contains(document.uuid) {
                try await api.update(document.toNetworkModel())
            } else {
                try await api.create(document.toNetworkModel())
            }

            document.isDirty = false

            try await storage.update(document)
        }
    }

    func updateLocalDocuments(
        _ localDocuments: [Document],
        _ remoteDocuments: [DocumentNetworking]
    ) async throws {
        let localMap = Dictionary(uniqueKeysWithValues: localDocuments.map { ($0.uuid, $0) })

        for remote in remoteDocuments {
            guard let local = localMap[remote.uuid] else {
                try await insertNewDocument(from: remote)
                continue
            }

            if remote.updatedAt > local.updatedAt {
                try await updateLocalDocument(local, with: remote)
            }
        }
    }

    func cleanupLocallyDeleted(
        _ localDocuments: [Document],
        _ remoteDocuments: [DocumentNetworking]
    ) async throws {
        let remoteUUIDs = Set(remoteDocuments.map { $0.uuid })

        for local in localDocuments {
            if !remoteUUIDs.contains(local.uuid), !local.isDirty {
                try await storage.delete(local)
            }
        }
    }
    
    func insertNewDocument(
        from remote: DocumentNetworking
    ) async throws {
        let newDoc = Document(
            id: remote.uuid,
            title: remote.title,
            imagePath: try? await downloadImage(
                imageUrl: remote.imageUrl,
                uuid: remote.uuid
            ),
            remoteImageURL: remote.imageUrl,
            icon: remote.icon.toDomain(),
            color: remote.color.toDomain(),
            description: remote.description,
            isFavorite: remote.isFavorite,
            createdAt: remote.createdAt,
            updatedAt: remote.updatedAt,
            isDirty: false,
            folder: await getDocumentFolder(remote),
            deleted: false
        )
        
        try await storage.create(newDoc)
    }
    
    func updateLocalDocument(
        _ local: Document,
        with remote: DocumentNetworking
    ) async throws {
        local.title = remote.title
        local.imagePath = try? await downloadImage(
            imageUrl: remote.imageUrl,
            uuid: remote.uuid
        )
        local.remoteImageURL = remote.imageUrl
        local.icon = remote.icon.toDomain()
        local.color = remote.color.toDomain()
        local.documentDescription = remote.description
        local.isFavorite = remote.isFavorite
        local.updatedAt = remote.updatedAt
        local.folder = await getDocumentFolder(remote)
        local.isDirty = false

        try await storage.update(local)
    }
    
    func downloadImage(
        imageUrl: String?,
        uuid: UUID
    ) async throws -> String? {
        guard let imageUrl else { return nil }
        
        var imagePath: String? = nil
        
        if let imageUrl = URL(string: imageUrl) {
            imagePath = try await imageService.downloadImage(
                from: imageUrl,
                id: uuid
            )
        }
        
        return imagePath
    }
    
    func getDocumentFolder(_ remote: DocumentNetworking) async -> Folder? {
        guard let folderId = remote.folderId else {
            return nil
        }
        
        return try? await folderRepository.getLocal(
            with: folderId
        )
    }
}

private extension Document {
    func toNetworkModel() -> DocumentNetworking {
        .init(
            id: uuid,
            title: title,
            imageUrl: remoteImageURL,
            icon: icon.toNetworkingIcon(),
            color: color.toNetworkingColor(),
            description: documentDescription,
            isFavorite: isFavorite,
            createdAt: createdAt,
            updatedAt: updatedAt,
            folderId: folder?.uuid
        )
    }
}
