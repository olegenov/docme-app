import Foundation
import SwiftUI


struct DocumentListView<ViewModel: DocumentListViewModel>: View {
    @Environment(\.theme) var theme
    @StateObject var viewModel: ViewModel
    
    let imageService: ImageService
    
    @State var isSearching: Bool = false
    
    var body: some View {
        MainContent {
            tabbarView
            
            MainScrollView {
                if !isSearching {
                    if viewModel.favorites.isNotEmpty {
                        favoriteSectionView
                    }
                    
                    if viewModel.folders.isNotEmpty {
                        foldersView
                    }
                    
                    documentCollection
                } else {
                    searchResults
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.documents)
        .animation(.easeInOut(duration: 0.3), value: isSearching)
        .task {
            await viewModel.loadData()
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
                        title: folder.name,
                        trailingText: "\(folder.documentCount)",
                        leadingView: .empty,
                        trailingView: .chevron,
                        onTapAction: { viewModel.selectFolder(folder) }
                    )
                    
                    if index < viewModel.folders.count - 1 {
                        SeparatorView()
                    }
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
