import Foundation
import SwiftData


final class AppDIContainer {
    let documentRepository: DocumentRepository
    let folderRepository: FolderRepository
    let fieldRepository: FieldRepository
    let imageService: ImageService
    
    init(modelContext: ModelContext) {
        guard let apiURL = URL(string: "http://localhost:8080") else {
            fatalError("Invalid base URL")
        }
        
        imageService = ImageServiceImpl()
        let networking = DefaultNetworkingService(baseURL: apiURL)
        
        // Folder
        let folderStorage = FolderStorageRepositoryImpl(context: modelContext)
        let folderNetworking = FolderNetworkingRepository(service: networking)
        
        self.folderRepository = FolderRepositoryImpl(
            storage: folderStorage,
            api: folderNetworking
        )
        
        // Field
        let fieldStorage = FieldStorageRepositoryImpl(context: modelContext)
        
        self.fieldRepository = FieldRepositoryImpl(storage: fieldStorage)
        
        // Document
        let documentStorage = DocumentStorageRepositoryImpl(context: modelContext)
        let documentNetworking = DocumentNetworkingRepository(service: networking)
        
        self.documentRepository = DocumentRepositoryImpl(
            storage: documentStorage,
            api: documentNetworking,
            folderRepository: folderRepository,
            fieldRepository: fieldRepository,
            imageService: imageService
        )
    }
}
