import Foundation


struct DocumentCardModel: Identifiable, Hashable {
    let id: UUID
    let imageUrl: String
    let title: String
    let icon: DocumentIcon
    let documentColor: DocumentColor
    let creationDate: Date
    var isFavorite: Bool
}
