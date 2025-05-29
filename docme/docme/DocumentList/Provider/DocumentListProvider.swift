import Foundation
import SwiftUI


protocol DocumentListProvider {
    func fetchFolders(for parentFolder: FolderCard?) async -> [FolderCard]
    func fetchDocuments() async -> [DocumentCard]
    func fetchDocuments(for parentFolder: FolderCard?) async -> [DocumentCard]
    
    func createNewFolder(
        with: UUID,
        named: String,
        in: FolderCard?,
        complition: (Bool) -> Void
    ) async
    
    func deleteFolder(
        with: UUID
    ) async
    
    func getSelectedTags() -> [DocumentCard.Color]
    func setSelectedTags(_ tags: [DocumentCard.Color])
    func toggleFavortite(for document: DocumentCard) async
    
    func sync() async
}

final class DocumentListProviderImpl: DocumentListProvider {
    enum Errors: Error {
        case documentNotFound
    }
    
    private let documentRepository: DocumentRepository
    private let folderRepository: FolderRepository
    
    @AppStorage("selectedTagsData") private var selectedTagsData: Data = Data()
    
    init(
        documentRepository: DocumentRepository,
        folderRepository: FolderRepository
    ) {
        self.documentRepository = documentRepository
        self.folderRepository = folderRepository
    }
    
    func fetchFolders(for parentFolder: FolderCard?) async -> [FolderCard] {
//        Task {
//            try await documentRepository.sync()
//            try await folderRepository.sync()
//        }
        
        do {
            let baseFolder = await getBaseFolder(folder: parentFolder)
            let folders: [Folder]
            if let baseFolder = baseFolder {
                folders = baseFolder.subfolders
            } else {
                folders = try await folderRepository.getSubFolders(of: nil)
            }
            
            var result = [FolderCard]()
            
            for folder in folders {
                let folderUI = folder.toUI(
                    with: try await folderRepository
                        .countDocuments(of: folder)
                )
                
                result.append(folderUI)
            }
            
            return result
        } catch {
            AppLogger.shared.error("Failed to fetch folders: \(error)")
            
            return []
        }
    }
    
    @MainActor
    func fetchDocuments() async -> [DocumentCard] {
        do {
            let documents = try await documentRepository.fetchLocal()
            
            return documents.map { $0.toCardUI() }
        } catch {
            AppLogger.shared.error("Failed to fetch documents: \(error)")
            
            return []
        }
    }
    
    func sync() async {
        do {
            await folderRepository.syncFolders()
            try await documentRepository.syncDocuments()
        } catch {
            
        }
    }
    
    @MainActor
    func fetchDocuments(for parentFolder: FolderCard?) async -> [DocumentCard] {
        do {
            let baseFolder = await getBaseFolder(folder: parentFolder)
            let documents = try await documentRepository.getDocuments(
                of: baseFolder
            )
            
            return documents.map { $0.toCardUI() }
        } catch {
            AppLogger.shared.error("Failed to fetch documents: \(error)")
            
            return []
        }
    }
    
    func createNewFolder(
        with uuid: UUID,
        named: String,
        in parentFolder: FolderCard?,
        complition: (Bool) -> Void
    ) async {
        do {
            let baseFolder = await getBaseFolder(folder: parentFolder)
            
            try await folderRepository.createLocal(
                .init(id: uuid, name: named, parentFolder: baseFolder)
            )
            
            complition(true)
        } catch {
            AppLogger.shared.error("Failed to create folder: \(error)")
            
            complition(false)
        }
    }
    
    func deleteFolder(with uuid: UUID) async {
        do {
            try await folderRepository.deleteLocal(with: uuid)
        } catch {
            AppLogger.shared.error("Failed to delete folder: \(error)")
        }
    }
    
    func getSelectedTags() -> [DocumentCard.Color] {
        guard let decoded = try? JSONDecoder().decode(
            [DocumentCard.Color].self,
            from: selectedTagsData
        ) else {
            return []
        }
        return decoded
    }
    
    func setSelectedTags(_ tags: [DocumentCard.Color]) {
        if let encoded = try? JSONEncoder().encode(tags) {
            selectedTagsData = encoded
        }
    }
    
    func toggleFavortite(for document: DocumentCard) async {
        do {
            let documentStorage = try await documentRepository.getDocument(
                with: document.id
            )
            
            guard let documentStorage else {
                throw Errors.documentNotFound
            }
            
            documentStorage.isFavorite = document.isFavorite
            
            try await documentRepository.saveLocal(documentStorage)
        } catch {
            AppLogger.shared.error("Failed to toggle favorite: \(error)")
        }
    }
    
    private func getBaseFolder(folder: FolderCard?) async -> Folder? {
        var baseFolder: Folder? = nil
        
        do {
            if let folderId = folder?.id {
                baseFolder = try await folderRepository.getLocal(
                    with: folderId
                )
            }
        } catch {
            AppLogger.shared.error("Failed to get base folder: \(error)")
        }
        
        return baseFolder
    }
}
