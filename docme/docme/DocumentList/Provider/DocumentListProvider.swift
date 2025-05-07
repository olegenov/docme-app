import Foundation


protocol DocumentListProvider {
    func fetchFolders() -> [FolderModel]
    func fetchDocuments() -> [DocumentCardModel]
}

class DocumentListProviderImpl: DocumentListProvider {
    func fetchFolders() -> [FolderModel] {
        return [
            .init(id: .init(), name: "folder 1", amount: 3),
            .init(id: .init(), name: "folder 2", amount: 0)
        ]
    }
    
    func fetchDocuments() -> [DocumentCardModel] {
        return [
            .init(id: .init(), imageUrl: "https://avatars.mds.yandex.net/i?id=3bed2771fae331e26384c18692e9a021_l-3692823-images-thumbs&n=13", title: "123", icon: .government, documentColor: .none, creationDate: .now, isFavorite: true),
            
            .init(id: .init(), imageUrl: "https://avatars.mds.yandex.net/i?id=3bed2771fae331e26384c18692e9a021_l-3692823-images-thumbs&n=13", title: "1234", icon: .driver, documentColor: .green, creationDate: .now, isFavorite: true),
            
            .init(id: .init(), imageUrl: "https://avatars.mds.yandex.net/i?id=3bed2771fae331e26384c18692e9a021_l-3692823-images-thumbs&n=13", title: "1235", icon: .tag, documentColor: .green, creationDate: .now, isFavorite: false)
        ]
    }
}
