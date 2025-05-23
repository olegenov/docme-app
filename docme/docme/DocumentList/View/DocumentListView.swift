import Foundation
import SwiftUI


struct DocumentListView<ViewModel: DocumentListViewModel>: View {
    @Environment(\.theme) var theme
    @StateObject var viewModel: ViewModel
    
    let imageService: ImageService
    
    @State var isSearching: Bool = false
    @State private var isDeletingFolderAlertPresented: Bool = false
    @State private var folderToDelete: FolderUI? = nil
    
    var body: some View {
        MainContent {
            tabbarView
            
            MainScrollView {
                if !isSearching {
                    if viewModel.favorites.isNotEmpty {
                        favoriteSectionView
                    }
                    
                    if viewModel.isFoldersSectionVisible {
                        foldersView
                    }
                    
                    documentCollection
                } else {
                    searchResults
                }
            }
        }
        .animation(.easeInOut, value: viewModel.documents)
        .animation(.easeInOut, value: isSearching)
        .animation(.easeInOut, value: viewModel.folders)
        .animation(.easeInOut, value: viewModel.creatingNewFolder)
        .task {
            await viewModel.loadData()
        }
        .alert(
            Captions.deleteFolderAlertTitle,
            isPresented: $isDeletingFolderAlertPresented
        ) {
            Button(Captions.yes, role: .destructive) {
                guard let folder = folderToDelete else {
                    return
                }
                viewModel.deleteFolder(folder)
                folderToDelete = nil
                isDeletingFolderAlertPresented = false
            }
            Button(Captions.no, role: .cancel) {
                folderToDelete = nil
                isDeletingFolderAlertPresented = false
            }
        } message: {
            Text(Captions.deleteFolderAlertDescription)
        }
        .onChange(of: folderToDelete) {
            isDeletingFolderAlertPresented = folderToDelete != nil
        }
    }
    
    private var tabbarView: some View {
        DocumentListTabbarView(
            selectedTags: viewModel.selectedTags,
            onSearchStart: {
                isSearching = true
            },
            onSearchClear: {
                viewModel.cancelSearch()
            },
            onSearchClose: {
                viewModel.cancelSearch()
                isSearching = false
            },
            onSearchChange: { searchText in
                viewModel.searchDocuments(by: searchText)
            },
            onFilterSelection: { tag in
                viewModel.selectTag(tag)
            },
            onCancelFilter: { tag in
                viewModel.deselectTag(tag)
            },
            onAllFilterSelection: {
                viewModel.selectAllTags()
            }
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
        TitledContent(title: Captions.myDocs) {
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
                }
            }
        }
    }
    
    private var documentCollection: some View {
        DocumentCollectionView(
            documents: viewModel.documents,
            imageService: imageService,
            onFavoriteToggle: viewModel.toggleFavorite
        ).padding(.horizontal, DS.Spacing.m8)
    }
    
    private var documentList: some View {
        LazyVStack(spacing: DS.Spacing.m8) {
            ForEach(viewModel.documents, id: \.self) { document in
                DocumentCollectionItemView(
                    displayType: .list,
                    document: document,
                    imageService: imageService
                )
            }
        }
    }
    
    private var searchResults: some View {
        TitledContent(title: Captions.search) {
            documentList
        }
    }
}
