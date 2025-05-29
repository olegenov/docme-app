import Foundation


struct DocumentNetworking: Codable {
    var uuid: UUID
    var title: String
    var imagePath: String?
    var remoteImageURL: String?
    var icon: String
    var color: String
    var documentDescription: String?
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
    var isDirty: Bool
    var deleted: Bool
    var folderUUID: UUID?
    var fields: [DocumentFieldNetworking]
}

struct DocumentFieldNetworking: Codable {
    var uuid: UUID
    var name: String
    var value: String
}
