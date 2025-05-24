import Foundation


protocol DocumentListViewModel: ObservableObject, AnyObject {
    var favorites: [DocumentCardUI] { get }
    var folders: [FolderUI] { get }
    var documents: [DocumentCardUI] { get }
    
    var selectedFolder: FolderUI? { get }
    
    var isFoldersSectionVisible: Bool { get }
    var newFolderName: String { get set }
    var creatingNewFolder: Bool { get set }
    
    func toggleFavorite(for card: DocumentCardUI)
    func searchDocuments(by query: String)
    func cancelSearch()
    
    var selectedTags: [DocumentCardUI.Color] { get set }
    func updateSelectedTags()
    func selectTag(_ tag: DocumentCardUI.Color)
    func deselectTag(_ tag: DocumentCardUI.Color)
    func selectAllTags()
    
    func selectFolder(_ folder: FolderUI)
    func goToParentFolder()
    func goToHomeFolder()
    
    func cancelCreatingNewFolder()
    func createNewFolder()
    func deleteFolder(_ folder: FolderUI)
    
    func loadData() async
}

@Observable
class DocumentListViewModelImpl: DocumentListViewModel {
    private(set) var favorites = [DocumentCardUI]()
    private(set) var documents = [DocumentCardUI]()
    private(set) var folders = [FolderUI]()
    
    var selectedTags = [DocumentCardUI.Color]() {
        didSet { provider.setSelectedTags(selectedTags) }
    }

    var newFolderName: String = ""
    var creatingNewFolder: Bool = false
    
    let selectedFolder: FolderUI?
    
    private var allDocuments: [DocumentCardUI] = []
    
    private let provider: DocumentListProvider
    private let router = Router.shared

    init(
        provider: DocumentListProvider,
        for folder: FolderUI? = nil
    ) {
        self.provider = provider
        self.selectedFolder = folder
    }
    
    @MainActor
    func loadData() async {
        folders = await provider.fetchFolders(for: selectedFolder)
        allDocuments = await provider.fetchDocuments(for: selectedFolder)
        
        updateDocumentFiltering()
        updateFavoriteDocuments()
    }
    
    func toggleFavorite(for card: DocumentCardUI) {
        guard let index = documents.firstIndex(
            where: { $0.id == card.id }
        ) else { return }
        
        //documents[index].isFavorite.toggle()
        
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
    
    func updateSelectedTags() {
        selectedTags = provider.getSelectedTags()
        updateDocumentFiltering()
        updateFavoriteDocuments()
    }
    
    func selectTag(_ tag: DocumentCardUI.Color) {
        selectedTags.append(tag)
        updateDocumentFiltering()
        updateFavoriteDocuments()
    }
    
    func deselectTag(_ tag: DocumentCardUI.Color) {
        selectedTags.removeAll { $0 == tag }
        updateDocumentFiltering()
        updateFavoriteDocuments()
    }
    
    func selectAllTags() {
        selectedTags.removeAll()
        updateDocumentFiltering()
        updateFavoriteDocuments()
    }
    
    func cancelCreatingNewFolder() {
        newFolderName = ""
        creatingNewFolder = false
    }
    
    var isFoldersSectionVisible: Bool {
        !folders.isEmpty || creatingNewFolder
    }
    
    func createNewFolder() {
        let uuid: UUID = UUID()
        let folderName = newFolderName
        let newFolderUI = FolderUI(
            id: uuid,
            name: folderName,
            documentCount: 0,
            loading: true
        )
        
        folders.append(newFolderUI)
        cancelCreatingNewFolder()
        
        Task {
            await provider.createNewFolder(
                with: uuid,
                named: folderName,
                complition: { success in
                    if !success {
                        folders.removeAll {
                            $0.id == uuid
                        }
                    } else {
                        folders.removeAll {
                            $0.id == uuid
                        }
                        folders.append(
                            .init(
                                id: uuid,
                                name: folderName,
                                documentCount: 0
                            )
                        )
                    }
                }
            )
        }
    }
    
    func deleteFolder(_ folder: FolderUI) {
        Task {
            await provider.deleteFolder(with: folder.id)
        }
        
        folders.removeAll { $0.id == folder.id }
    }
    
    func selectFolder(_ folder: FolderUI) {
        Router.shared.pushScreen(
            DocumentListRoutes.folderDetails(folder: folder),
            for: .documents
        )
    }
    
    func goToParentFolder() {
        Router.shared.popScreen(for: .documents)
    }
    
    func goToHomeFolder() {
        Router.shared.resetToRoot(for: .documents)
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
            selectedTags.contains($0.color) || selectedTags.isEmpty
        }
    }
}
