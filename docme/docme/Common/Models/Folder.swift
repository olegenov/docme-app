import Foundation
import SwiftData

@Model
final class Folder: UUIDModel {
    var uuid: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    var isDirty: Bool
    var deleted: Bool
    
    @Relationship(inverse: \Folder.parentFolder)
    var subfolders: [Folder] = []

    @Relationship(deleteRule: .cascade)
    var parentFolder: Folder?
    
    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        parentFolder: Folder? = nil,
        isDirty: Bool = false,
        deleted: Bool = false
    ) {
        self.uuid = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.parentFolder = parentFolder
        self.isDirty = isDirty
        self.deleted = deleted
    }
}
