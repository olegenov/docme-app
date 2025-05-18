import Foundation

struct FolderUI: Identifiable, Hashable {
    let id: UUID
    let name: String
    let documentCount: Int
    let parentFolderName: String?
    
    init(
        id: UUID,
        name: String,
        documentCount: Int,
        parentFolderName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.documentCount = documentCount
        self.parentFolderName = parentFolderName
    }
}

extension Folder {
    func toUI(with count: Int = 0) -> FolderUI {
        .init(
            id: uuid,
            name: name,
            documentCount: count,
            parentFolderName: parentFolder?.name
        )
    }
}
