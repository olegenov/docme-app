import Foundation


struct FolderNetworking: Codable {
    var uuid: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    var isDirty: Bool
    var deleted: Bool
    var parentFolderUUID: UUID?
}

extension Folder {
    func toNetworkingModel() -> FolderNetworking {
        FolderNetworking(
            uuid: uuid,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDirty: isDirty,
            deleted: deleted,
            parentFolderUUID: parentFolder?.uuid
        )
    }
}

extension FolderNetworking {
    func toLocalModel(parent: Folder?) -> Folder {
        Folder(
            id: uuid,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            parentFolder: parent,
            isDirty: false,
            deleted: deleted
        )
    }
}
