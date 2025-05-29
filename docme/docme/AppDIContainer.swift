import Foundation
import SwiftData


final class AppDIContainer {
    let documentRepository: DocumentRepository
    let folderRepository: FolderRepository
    let fieldRepository: FieldRepository
    let imageService: ImageService
    let authNetworking: AuthNetworkingRepository
    
    init(modelContext: ModelContext) {
        guard let apiURL = URL(string: "http://127.0.0.1:8080/api") else {
            fatalError("Invalid base URL")
        }
        
        imageService = ImageServiceImpl()
        let networking = DefaultNetworkingService(baseURL: apiURL)
        
        // Auth
        self.authNetworking = AuthNetworkingRepository(networkingService: networking)
        
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
