import Foundation


protocol DocumentRepository {
    func syncDocuments() async throws
    func fetchLocal() async throws -> [Document]
    func createLocal(_ document: Document) async throws
    func getDocuments(of folder: Folder?) async throws -> [Document]
    func getDocument(with id: UUID) async throws -> Document?
    func deleteDocument(_ document: Document) async throws
    func saveLocal(_ document: Document) async throws
}

actor DocumentRepositoryImpl: DocumentRepository {
    private let storage: DocumentStorageRepository
    private let api: DocumentNetworkingRepository
    private let folderRepository: FolderRepository
    private let fieldRepository: FieldRepository
    private let imageService: ImageService
    
    init(
        storage: DocumentStorageRepository,
        api: DocumentNetworkingRepository,
        folderRepository: FolderRepository,
        fieldRepository: FieldRepository,
        imageService: ImageService
    ) {
        self.storage = storage
        self.api = api
        self.folderRepository = folderRepository
        self.fieldRepository = fieldRepository
        self.imageService = imageService
    }

    func syncDocuments() async {
        do {
            try await sendLocalChanges()
            try await getUpdates()
        } catch {
            AppLogger.shared.error("Sync error: \(error)")
        }
    }


    func fetchLocal() async throws -> [Document] {
        try await storage.fetch().filter { !$0.deleted }
    }
    
    func createLocal(_ document: Document) async throws {
        document.isNew = true
        try await storage.create(document)
    }
    
    func saveLocal(_ document: Document) async throws {
        document.updatedAt = Date()
        try await storage.update(document)
    }
    
    func getDocuments(of folder: Folder?) async throws -> [Document] {
        try await storage.getDocuments(of: folder).filter { !$0.deleted }
    }
    
    func getDocument(with id: UUID) async throws -> Document? {
        try await storage.getDocument(with: id)
    }
    
    func deleteDocument(_ document: Document) async throws {
        document.updatedAt = Date()
        try await storage.delete(document)
    }
    
    private func getLocalFolder(id: UUID?) async -> Folder? {
        var folder: Folder? = nil
        
        if let id, let foundFolder = try? await folderRepository.getLocal(with: id) {
            folder = foundFolder
        }
        
        return folder
    }
}

private extension DocumentRepositoryImpl {
    func sendLocalChanges() async throws {
        let localDocuments = try await storage.fetch()

        for doc in localDocuments {
            let netDoc = doc.toNetworkingModel()

            if doc.deleted {
                await api.delete(document: netDoc) { _ in }
                try await storage.delete(doc)
                continue
            }

            if doc.isNew {
                await api.create(document: netDoc) { [weak self] result in
                    guard let self else { return }
                    
                    if case .success = result {
                        doc.isNew = false
                        doc.isDirty = false
                        
                        try? await storage.update(doc)
                    }
                }
            } else if doc.isDirty {
                await api.update(document: netDoc) { [weak self] result in
                    guard let self else { return }
                    
                    if case .success = result {
                        doc.isDirty = false
                        try? await storage.update(doc)
                    }
                }
            }
        }
    }
    
    func getUpdates() async throws {
        var remoteChanges: [DocumentNetworking] = []
        await api.fetchChanges { result in
            switch result {
            case .success(let docs): remoteChanges = docs
            case .failure(let err): AppLogger.shared.error("Sync error: \(err)")
            }
        }
        
        for remote in remoteChanges {
            guard let local = try await storage.getDocument(with: remote.uuid) else {
                let newDoc = Document(
                    id: remote.uuid,
                    title: remote.title,
                    imagePath: try await downloadImage(imageUrl: remote.remoteImageURL, uuid: remote.uuid),
                    remoteImageURL: remote.remoteImageURL,
                    icon: Document.Icon(rawValue: remote.icon) ?? .passport,
                    color: Document.Color(rawValue: remote.color) ?? .none,
                    description: remote.documentDescription,
                    isFavorite: remote.isFavorite,
                    createdAt: remote.createdAt,
                    updatedAt: remote.updatedAt,
                    isDirty: false,
                    folder: await getLocalFolder(id: remote.folderUUID),
                    deleted: remote.deleted,
                    isNew: false
                )
                newDoc.fields = remote.fields.map {
                    DocumentField(id: $0.uuid, name: $0.name, value: $0.value, document: newDoc)
                }
                
                try await storage.create(newDoc)
                try await fieldRepository.replaceFields(for: newDoc, with: newDoc.fields)
                
                continue
            }

            if remote.updatedAt > local.updatedAt {
                let fields = remote.fields.map {
                    DocumentField(id: $0.uuid, name: $0.name, value: $0.value, document: local)
                }
                
                local.title = remote.title
                local.imagePath = try await downloadImage(imageUrl: remote.remoteImageURL, uuid: remote.uuid)
                local.remoteImageURL = remote.remoteImageURL
                local.icon = Document.Icon(rawValue: remote.icon) ?? .passport
                local.color = Document.Color(rawValue: remote.color) ?? .none
                local.documentDescription = remote.documentDescription
                local.isFavorite = remote.isFavorite
                local.updatedAt = remote.updatedAt
                local.deleted = remote.deleted
                local.folder = await getLocalFolder(id: remote.folderUUID)
                local.fields = remote.fields.map {
                    DocumentField(id: $0.uuid, name: $0.name, value: $0.value, document: local)
                }
                local.isDirty = false
                local.isNew = false
                
                try await fieldRepository.replaceFields(for: local, with: fields)
                try await storage.update(local)
            }
        }
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
}

extension Document {
    func toNetworkingModel() -> DocumentNetworking {
        .init(
            uuid: self.uuid,
            title: self.title,
            imagePath: self.imagePath,
            remoteImageURL: self.remoteImageURL,
            icon: self.icon.rawValue,
            color: self.color.rawValue,
            documentDescription: self.documentDescription,
            isFavorite: self.isFavorite,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            isDirty: self.isDirty,
            deleted: self.deleted,
            folderUUID: self.folder?.uuid,
            fields: self.fields.map { $0.toNetworkingModel() }
        )
    }
}

extension DocumentField {
    func toNetworkingModel() -> DocumentFieldNetworking {
        .init(uuid: self.uuid, name: self.name, value: self.value)
    }
}
