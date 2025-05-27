import Foundation
import SwiftUI


protocol DocumentListProvider {
    func fetchFolders(for parentFolder: FolderUI?) async -> [FolderUI]
    func fetchDocuments(for parentFolder: FolderUI?) async -> [DocumentCardUI]
    
    func createNewFolder(
        with: UUID,
        named: String,
        in: FolderUI?,
        complition: (Bool) -> Void
    ) async
    
    func deleteFolder(
        with: UUID
    ) async
    
    func getSelectedTags() -> [DocumentCardUI.Color]
    func setSelectedTags(_ tags: [DocumentCardUI.Color])
}

final class DocumentListProviderImpl: DocumentListProvider {
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
    
    func fetchFolders(for parentFolder: FolderUI?) async -> [FolderUI] {
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
            
            var result = [FolderUI]()
            
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
    func fetchDocuments(for parentFolder: FolderUI?) async -> [DocumentCardUI] {
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
        in parentFolder: FolderUI?,
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
    
    func getSelectedTags() -> [DocumentCardUI.Color] {
        guard let decoded = try? JSONDecoder().decode(
            [DocumentCardUI.Color].self,
            from: selectedTagsData
        ) else {
            return []
        }
        return decoded
    }
    
    func setSelectedTags(_ tags: [DocumentCardUI.Color]) {
        if let encoded = try? JSONEncoder().encode(tags) {
            selectedTagsData = encoded
        }
    }
    
    private func getBaseFolder(folder: FolderUI?) async -> Folder? {
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
