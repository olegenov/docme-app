import Foundation


protocol FolderDetailsViewModel: ObservableObject, AnyObject {
    var selectedFolder: FolderUI { get }
    
    var folders: [FolderUI] { get }
    var documents: [DocumentCardUI] { get }
    
    var selectedTags: [DocumentCardUI.Color] { get }
    
    func toggleFavorite(for card: DocumentCardUI)
    
    func selectTag(_ tag: DocumentCardUI.Color)
    func deselectTag(_ tag: DocumentCardUI.Color)
    func selectAllTags()
    
    func selectFolder(_ folder: FolderUI)
    func closeFolder()
    func closeAllFolders()
    
    func loadData() async
}

class FolderDetailsViewModelImpl: FolderDetailsViewModel {
    let selectedFolder: FolderUI
    
    @Published private(set) var documents = [DocumentCardUI]()
    @Published private(set) var folders = [FolderUI]()
    @Published private(set) var selectedTags = [DocumentCardUI.Color]()
    
    private var allDocuments: [DocumentCardUI] = []

    private let provider: FolderDetailsProvider
    private let router = Router.shared

    init(folder: FolderUI, provider: FolderDetailsProvider) {
        self.selectedFolder = folder
        self.provider = provider
    }
    
    func loadData() async {
        folders = await provider.fetchFolders(for: selectedFolder.id)
        
        allDocuments = await provider.fetchDocuments(
            for: selectedFolder.id
        )
        
        updateDocumentFiltering()
    }
    
    func toggleFavorite(for card: DocumentCardUI) {
        guard let index = documents.firstIndex(
            where: { $0.id == card.id }
        ) else { return }
        
        //documents[index].isFavorite.toggle()
    }
    
    func selectTag(_ tag: DocumentCardUI.Color) {
        selectedTags.append(tag)
        updateDocumentFiltering()
    }
    
    func deselectTag(_ tag: DocumentCardUI.Color) {
        selectedTags.removeAll { $0 == tag }
        updateDocumentFiltering()
    }
    
    func selectAllTags() {
        selectedTags.removeAll()
        updateDocumentFiltering()
    }
    
    func selectFolder(_ folder: FolderUI) {
        Router.shared.pushScreen(
            DocumentListRoutes.folderDetails(
                folder: folder
            ),
            for: .documents
        )
    }
    
    func closeFolder() {
        Router.shared.popScreen(for: .documents)
    }
    
    func closeAllFolders() {
        Router.shared.resetToRoot(for: .documents)
    }
}

private extension FolderDetailsViewModelImpl {
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
