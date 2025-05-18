import Foundation


protocol FolderDetailsProvider {
    func fetchFolders(for uuid: UUID) async -> [FolderUI]
    func fetchDocuments(for uuid: UUID) async -> [DocumentCardUI]
}

class FolderDetailsProviderImpl: FolderDetailsProvider {
    private let documentRepository: DocumentRepository
    private let folderRepository: FolderRepository
    
    init(
        documentRepository: DocumentRepository,
        folderRepository: FolderRepository
    ) {
        self.documentRepository = documentRepository
        self.folderRepository = folderRepository
    }
    
    
    func fetchFolders(for uuid: UUID) async -> [FolderUI] {
        guard let folder = try? await folderRepository.getLocal(with: uuid)
        else {
            AppLogger.shared.error("Folder \(uuid) not found")
            
            return []
        }
        
        guard let subfolders = try? await folderRepository.getSubFolders(
            of: folder
        ) else {
            AppLogger.shared.error("Subfolders of \(uuid) fetch error")
            
            return []
        }
            
        var result = [FolderUI]()
        
        for folder in subfolders {
            guard let amount = try? await folderRepository.countDocuments(of: folder)
            else { continue }
            
            let folderUI = folder.toUI(
                with: amount
            )
            
            result.append(folderUI)
        }
        
        return result
    }
    
    func fetchDocuments(for uuid: UUID) async -> [DocumentCardUI] {
        guard let folder = try? await folderRepository.getLocal(with: uuid)
        else {
            AppLogger.shared.error("Folder \(uuid) not found")
            
            return []
        }
        
        guard let documents = try? await documentRepository.getDocuments(
            of: folder
        ) else {
            AppLogger.shared.error("Document of \(uuid) fetch error")
            
            return []
        }
            
        return documents.map { $0.toCardUI() }
    }
}
