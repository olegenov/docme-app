import Foundation

struct FolderUI: Identifiable, Hashable {
    let id: UUID
    let name: String
    let documentCount: Int
    let parentFolderName: String?
    let loading: Bool
    
    init(
        id: UUID,
        name: String,
        documentCount: Int,
        parentFolderName: String? = nil,
        loading: Bool = false
    ) {
        self.id = id
        self.name = name
        self.documentCount = documentCount
        self.parentFolderName = parentFolderName
        self.loading = loading
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
