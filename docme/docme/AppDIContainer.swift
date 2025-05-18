import Foundation
import SwiftData


final class AppDIContainer {
    let documentRepository: DocumentRepository
    let folderRepository: FolderRepository
    
    init(modelContext: ModelContext) {
        guard let apiURL = URL(string: "http://localhost:8080") else {
            fatalError("Invalid base URL")
        }
        
        let networking = DefaultNetworkingService(baseURL: apiURL)
        
        // Folder
        let folderStorage = FolderStorageRepositoryImpl(context: modelContext)
        let folderNetworking = FolderNetworkingRepository(service: networking)
        
        self.folderRepository = FolderRepositoryImpl(
            storage: folderStorage,
            api: folderNetworking
        )
        
        // Document
        let documentStorage = DocumentStorageRepositoryImpl(context: modelContext)
        let documentNetworking = DocumentNetworkingRepository(service: networking)
        
        self.documentRepository = DocumentRepositoryImpl(
            storage: documentStorage,
            api: documentNetworking,
            folderRepository: folderRepository
        )
    }
}
