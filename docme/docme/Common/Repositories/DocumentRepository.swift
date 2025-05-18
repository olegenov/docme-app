import Foundation


protocol DocumentRepository {
    func sync() async throws
    func fetchLocal() async throws -> [Document]
    func createLocal(_ document: Document) async throws
    func getDocuments(of folder: Folder) async throws -> [Document]
}

final class DocumentRepositoryImpl: DocumentRepository {
    private let storage: DocumentStorageRepository
    private let api: DocumentNetworkingRepository
    private let folderRepository: FolderRepository

    init(
        storage: DocumentStorageRepository,
        api: DocumentNetworkingRepository,
        folderRepository: FolderRepository
    ) {
        self.storage = storage
        self.api = api
        self.folderRepository = folderRepository
    }

    func sync() async throws {
        let remoteDocuments = try await api.fetchAll()
        let localDocuments = try await storage.fetch()

        let dirtyDocuments = localDocuments.filter { !$0.isSynced }

        try await syncDirtyDocuments(
            dirtyDocuments,
            remoteDocuments
        )

        try await updateLocal(
            localDocuments,
            remoteDocuments
        )

        try await deleteRemoteDocuments(
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
    
    func getDocuments(of folder: Folder) async throws -> [Document] {
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
                try await api.delete(uuid: document.uuid)
                try await storage.delete(document)
                continue
            }

            if remoteUUIDs.contains(document.uuid) {
                try await api.update(document.toNetworkModel())
            } else {
                try await api.create(document.toNetworkModel())
            }

            document.isSynced = true
            document.updatedAt = Date()

            try await storage.insertOrUpdate(document)
        }
    }

    func updateLocal(
        _ localDocuments: [Document],
        _ remoteDocuments: [DocumentNetworking]
    ) async throws {
        let localMap = Dictionary(uniqueKeysWithValues: localDocuments.map { ($0.uuid, $0) })

        for remote in remoteDocuments {
            guard let local = localMap[remote.uuid] else {
                let folder = try await folderRepository.getLocal(with: remote.folderId)
                let newDoc = Document(
                    id: remote.uuid,
                    title: remote.title,
                    icon: remote.icon.toDomain(),
                    color: remote.color.toDomain(),
                    description: remote.description,
                    isFavorite: remote.isFavorite,
                    createdAt: remote.createdAt,
                    updatedAt: remote.updatedAt,
                    isSynced: true,
                    folder: folder,
                    deleted: false
                )
                try await storage.insertOrUpdate(newDoc)
                continue
            }

            if local.isSynced {
                continue
            }

            local.title = remote.title
            local.icon = remote.icon.toDomain()
            local.color = remote.color.toDomain()
            local.documentDescription = remote.description
            local.isFavorite = remote.isFavorite
            local.updatedAt = remote.updatedAt
            local.folder = try await folderRepository.getLocal(with: remote.folderId)
            local.isSynced = true

            try await storage.insertOrUpdate(local)
        }
    }

    func deleteRemoteDocuments(
        _ localDocuments: [Document],
        _ remoteDocuments: [DocumentNetworking]
    ) async throws {
        let remoteUUIDs = Set(remoteDocuments.map { $0.uuid })

        for local in localDocuments {
            if !remoteUUIDs.contains(local.uuid), local.isSynced {
                try await storage.delete(local)
            }
        }
    }
}

private extension Document {
    func toNetworkModel() -> DocumentNetworking {
        .init(
            id: uuid,
            title: title,
            imageUrl: "",
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
