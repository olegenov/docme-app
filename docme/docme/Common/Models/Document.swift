import Foundation
import SwiftData


@Model
final class Document: UUIDModel {
    var uuid: UUID
    var title: String
    var icon: Icon
    var color: Color
    var documentDescription: String?
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
    var isSynced: Bool
    var deleted: Bool
    
    @Relationship(deleteRule: .nullify) var folder: Folder?
    
    enum Icon: String, Codable {
        case passport
        case driver
        case government
        case international
        case tag
    }
    
    enum Color: String, Codable {
        case none
        case red
        case green
        case yellow
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        icon: Icon,
        color: Color,
        description: String? = nil,
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isSynced: Bool = false,
        folder: Folder? = nil,
        deleted: Bool = false
    ) {
        self.uuid = id
        self.title = title
        self.icon = icon
        self.color = color
        self.documentDescription = description
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSynced = isSynced
        self.folder = folder
        self.deleted = deleted
    }
}
