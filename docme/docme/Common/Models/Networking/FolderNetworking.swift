import Foundation


struct FolderNetworking {
    let uuid: UUID
    let name: String
    let createdAt: Date
    let updatedAt: Date
    let parentFolderId: UUID?
    
    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        parentFolderId: UUID? = nil
    ) {
        self.uuid = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.parentFolderId = parentFolderId
    }
}
