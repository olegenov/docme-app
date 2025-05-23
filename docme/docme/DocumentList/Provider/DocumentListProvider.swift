import Foundation


protocol DocumentListProvider {
    func fetchFolders() async -> [FolderUI]
    func fetchDocuments() async -> [DocumentCardUI]
    
    func createNewFolder(
        with: UUID,
        named: String,
        complition: (Bool) -> Void
    ) async
    
    func deleteFolder(
        with: UUID
    ) async
}

class DocumentListProviderImpl: DocumentListProvider {
    private let documentRepository: DocumentRepository
    private let folderRepository: FolderRepository
    
    init(
        documentRepository: DocumentRepository,
        folderRepository: FolderRepository
    ) {
        self.documentRepository = documentRepository
        self.folderRepository = folderRepository
    }
    
    func fetchFolders() async -> [FolderUI] {
//        Task {
//            try await documentRepository.sync()
//            try await folderRepository.sync()
//        }
        
        do {
            let folders = try await folderRepository.fetchLocal()
            
            var result = [FolderUI]()
            
            for folder in folders {
                let folderUI = folder.toUI(
                    with: try await folderRepository.countDocuments(of: folder)
                )
                
                result.append(folderUI)
            }
            
            return result
        } catch {
            AppLogger.shared.error("Failed to fetch folders: \(error)")
            
            return []
        }
    }
    
    func fetchDocuments() async -> [DocumentCardUI] {
        do {
            let documents = try await documentRepository.fetchLocal()
            
            return documents.map { $0.toCardUI() }
        } catch {
            AppLogger.shared.error("Failed to fetch documents: \(error)")
            
            return []
        }
    }
    
    func createNewFolder(
        with uuid: UUID,
        named: String,
        complition: (Bool) -> Void
    ) async {
        do {
            try await folderRepository.createLocal(
                .init(id: uuid, name: named)
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
}
