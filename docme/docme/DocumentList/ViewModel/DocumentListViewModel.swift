import Foundation


protocol DocumentListViewModel: ObservableObject, AnyObject {
    var favorites: [DocumentCardModel] { get }
    var folders: [FolderModel] { get }
    var documents: [DocumentCardModel] { get }
    var selectedTags: [DocumentColor] { get }
    
    func toggleFavorite(for card: DocumentCardModel)
    func searchDocuments(by query: String)
    func cancelSearch()
    
    func selectTag(_ tag: DocumentColor)
    func deselectTag(_ tag: DocumentColor)
    func selectAllTags()
}

class DocumentListViewModelImpl: DocumentListViewModel {
    @Published private(set) var favorites = [DocumentCardModel]()
    @Published private(set) var documents = [DocumentCardModel]()
    @Published private(set) var folders = [FolderModel]()
    @Published private(set) var selectedTags = [DocumentColor]()
    
    private var allDocuments: [DocumentCardModel] = []
    
    private let provider: DocumentListProvider

    init(provider: DocumentListProvider) {
        self.provider = provider
        
        loadData()
    }
    
    func loadData() {
        folders = provider.fetchFolders()
        allDocuments = provider.fetchDocuments()
        
        updateDocumentFiltering()
        updateFavoriteDocuments()
    }
    
    func toggleFavorite(for card: DocumentCardModel) {
        guard let index = documents.firstIndex(
            where: { $0.id == card.id }
        ) else { return }
        
        documents[index].isFavorite.toggle()
        
        updateFavoriteDocuments()
    }
    
    func searchDocuments(by query: String) {
        documents = allDocuments.filter {
            $0.title.lowercased().contains(query.lowercased())
        }
    }
    
    func cancelSearch() {
        documents = allDocuments
    }
    
    func selectTag(_ tag: DocumentColor) {
        selectedTags.append(tag)
        updateDocumentFiltering()
        updateFavoriteDocuments()
    }
    
    func deselectTag(_ tag: DocumentColor) {
        selectedTags.removeAll { $0 == tag }
        updateDocumentFiltering()
        updateFavoriteDocuments()
    }
    
    func selectAllTags() {
        selectedTags.removeAll()
        updateDocumentFiltering()
        updateFavoriteDocuments()
    }
}


private extension DocumentListViewModelImpl {
    func updateFavoriteDocuments() {
        favorites = documents.filter { $0.isFavorite }
    }
    
    func updateDocumentFiltering() {
        if selectedTags.isEmpty {
            documents = allDocuments
            return
        }
        
        documents = allDocuments.filter {
            selectedTags.contains($0.documentColor) || selectedTags.isEmpty
        }
    }
}
