import Foundation
import SwiftUI


struct DocumentListView<ViewModel: DocumentListViewModel>: View {
    @Environment(\.theme) var theme
    @StateObject var viewModel: ViewModel
    
    let imageService: ImageService
    
    @State private var isDeletingFolderAlertPresented: Bool = false
    @State private var folderToDelete: FolderUI? = nil
    
    @State private var isSearching: Bool = false
    @State private var tabbarState: DocumentListTabbarView.TabbarState = .none
    
    @FocusState private var newFolderFocused: Bool
    
    var body: some View {
        MainContent {
            tabbarView
            
            MainScrollView {
                if viewModel.selectedFolder != nil {
                    folderDetailsView
                } else {
                    documentsListView
                }
            }
        }
        .animation(.easeInOut, value: viewModel.documents)
        .animation(.easeInOut, value: viewModel.folders)
        .animation(.easeInOut, value: viewModel.creatingNewFolder)
        .task {
            await viewModel.loadData()
        }
        .onAppear() {
            tabbarState = defaultTabbarState
            viewModel.updateSelectedTags()
        }
        .deleteFolderAlert(
            isPresented: $isDeletingFolderAlertPresented,
            onDeleteFolder: {
                guard let folder = folderToDelete else {
                    return
                }
                viewModel.deleteFolder(folder)
                folderToDelete = nil
                isDeletingFolderAlertPresented = false
            },
            onCancel: {
                folderToDelete = nil
                isDeletingFolderAlertPresented = false
            }
        )
        .onChange(of: folderToDelete) {
            isDeletingFolderAlertPresented = folderToDelete != nil
        }
        .hideKeyboardOnDrag()
    }
    
    @ViewBuilder
    private var documentsListView: some View {
        if !isSearching {
            if viewModel.favorites.isNotEmpty {
                favoriteSectionView
            }
            
            TitledContent(title: Captions.myDocs) {
                if viewModel.folders.isNotEmpty ||
                    viewModel.creatingNewFolder {
                    foldersView
                }
                
                documentCollection
            }
        } else {
            searchResults
        }
    }
    
    private var folderDetailsView: some View {
        TitledContent(title: viewModel.selectedFolder?.name ?? "") {
            if viewModel.folders.isNotEmpty ||
                viewModel.creatingNewFolder {
                foldersView
            }
            
            documentCollection
        }
    }
    
    private var tabbarView: some View {
        DocumentListTabbarView(
            state: $tabbarState
        ).padding(.horizontal, DS.Spacing.m8)
    }
    
    private var favoriteSectionView: some View {
        TitledContent(title: Captions.favotites) {
            ScrollView(.horizontal) {
                HStack(spacing: DS.Spacing.m4) {
                    ForEach(viewModel.favorites) { favorite in
                        DocumentCollectionItemView(
                            displayType: .favorite,
                            document: favorite,
                            imageService: imageService,
                            onFavoriteToggle: viewModel.toggleFavorite
                        )
                    }
                }
            }
            .scrollClipDisabled()
            .scrollIndicators(.hidden)
        }
    }
    
    private var foldersView: some View {
        ItemsListView {
            ForEach(Array(viewModel.folders.enumerated()), id: \.element.id) { index, folder in
                ListItemView(
                    configuration: .defaultStyle(
                        title: folder.name,
                        leadingView: .empty
                    ),
                    trailingText: "\(folder.documentCount)",
                    trailingView: folder.loading ? .loading : .chevron,
                    onTapAction: {
                        guard !folder.loading else { return }
                        viewModel.selectFolder(folder)
                    },
                    onDeleteAction: {
                        folderToDelete = folder
                    }
                )
                
                if index < viewModel.folders.count - 1 || viewModel.creatingNewFolder {
                    SeparatorView()
                }
            }
            
            if viewModel.creatingNewFolder {
                ListItemView(
                    configuration: .editing(
                        placeholder: Captions.newFolder,
                        title: $viewModel.newFolderName
                    ),
                    trailingView: viewModel.newFolderName.isEmpty ?
                        .delete(action: viewModel.cancelCreatingNewFolder) :
                            .save(
                                action: viewModel.createNewFolder
                            )
                )
                .focused($newFolderFocused)
                .onAppear() {
                    newFolderFocused = true
                }
            }
        }
    }
    
    private var documentCollection: some View {
        DocumentCollectionView(
            documents: viewModel.documents,
            imageService: imageService,
            onFavoriteToggle: viewModel.toggleFavorite,
            onDocumentTap: viewModel.openDocument
        )
    }
    
    private var documentList: some View {
        LazyVStack(spacing: DS.Spacing.m8) {
            ForEach(viewModel.documents, id: \.self) { document in
                DocumentCollectionItemView(
                    displayType: .list,
                    document: document,
                    imageService: imageService,
                    onDocumentTap: viewModel.openDocument
                )
            }
        }
    }
    
    private var searchResults: some View {
        TitledContent(title: Captions.search) {
            documentList
        }
    }
    
    var defaultTabbarState: DocumentListTabbarView.TabbarState {
        if let folder = viewModel.selectedFolder {
            .folderDetails(
                folder: folder,
                selectedTags: $viewModel.selectedTags,
                onParentFolderTap: viewModel.goToParentFolder,
                onHomeTap: viewModel.goToHomeFolder,
                onFilterTap: {
                    tabbarState = filterTabbarState
                }
            )
        } else {
            .defaultView(
                onSearchTap: {
                    isSearching = true
                    tabbarState = searchTabbartState
                },
                onFilterTap: {
                    tabbarState = filterTabbarState
                },
                selectedTags: $viewModel.selectedTags
            )
        }
    }
    
    var filterTabbarState: DocumentListTabbarView.TabbarState {
        .filter(
            selectedTags: $viewModel.selectedTags,
            onFilterSelection: { filter in
                viewModel.selectTag(filter)
            },
            onCancelFilter: { filter in
                viewModel.deselectTag(filter)
            },
            onAllFilterSelection: viewModel.selectAllTags,
            onClose: {
                tabbarState = defaultTabbarState
            }
        )
    }
    
    var searchTabbartState: DocumentListTabbarView.TabbarState {
        .search(
            onSearchClear: viewModel.cancelSearch,
            onSearchClose: {
                viewModel.cancelSearch()
                isSearching = false
                tabbarState = defaultTabbarState
            },
            onSearchChange: { searchText in
                viewModel.searchDocuments(by: searchText)
            }
        )
    }
}


private struct DeleteFolderAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    let ononDeleteFolder: () -> Void
    let onCancel: () -> Void

    func body(content: Content) -> some View {
        content
            .alert(
                Captions.deleteFolderAlertTitle,
                isPresented: $isPresented
            ) {
                Button(Captions.yes, role: .destructive) {
                    ononDeleteFolder()
                }
                Button(Captions.no, role: .cancel) {
                    onCancel()
                }
            } message: {
                Text(Captions.deleteFolderAlertDescription)
            }
    }
}


private extension View {
    func deleteFolderAlert(
        isPresented: Binding<Bool>,
        onDeleteFolder: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.modifier(DeleteFolderAlertModifier(
            isPresented: isPresented,
            ononDeleteFolder: onDeleteFolder,
            onCancel: onCancel
        ))
    }
}
