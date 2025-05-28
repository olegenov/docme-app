import Foundation
import SwiftData


@Model
final class Document: UUIDModel {
    var uuid: UUID
    var title: String
    var imagePath: String?
    var remoteImageURL: String?
    var icon: Icon
    var color: Color
    var documentDescription: String?
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
    var isDirty: Bool
    var deleted: Bool
    
    @Relationship(deleteRule: .cascade) var folder: Folder?
    
    @Relationship(inverse: \DocumentField.document)
    var fields: [DocumentField] = []
    
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
        imagePath: String?,
        remoteImageURL: String?,
        icon: Icon,
        color: Color,
        description: String? = nil,
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isDirty: Bool = false,
        folder: Folder? = nil,
        deleted: Bool = false
    ) {
        self.uuid = id
        self.title = title
        self.imagePath = imagePath
        self.remoteImageURL = remoteImageURL
        self.icon = icon
        self.color = color
        self.documentDescription = description
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDirty = isDirty
        self.folder = folder
        self.deleted = deleted
    }
}
