import Foundation
import SwiftUI


struct FolderDetailsView<ViewModel: FolderDetailsViewModel>: View {
    @Environment(\.theme) var theme
    @StateObject var viewModel: ViewModel
    
    let imageService: ImageService
    
    var body: some View {
        MainContent {
            tabbarView
            
            MainScrollView {
                if viewModel.folders.isNotEmpty {
                    foldersView
                }
                
                documentCollection
            }
        }
        .animation(.easeInOut, value: viewModel.documents)
        .task {
            await viewModel.loadData()
        }
    }
    
    private var tabbarView: some View {
        FolderDetailsTabbarView(
            selectedTags: viewModel.selectedTags,
            onBackTap: {
                viewModel.closeFolder()
            },
            onFilterSelection: { tag in
                viewModel.selectTag(tag)
            },
            onCancelFilter: { tag in
                viewModel.deselectTag(tag)
            },
            onAllFilterSelection: {
                viewModel.selectAllTags()
            },
            isHomeVisible: viewModel.selectedFolder.parentFolderName != nil,
            onHomeTap: {
                viewModel.closeAllFolders()
            }
        ).padding(.horizontal, DS.Spacing.m8)
    }
    
    private var foldersView: some View {
        TitledContent(title: viewModel.selectedFolder.name) {
            ItemsListView {
                ForEach(Array(viewModel.folders.enumerated()), id: \.element.id) { index, folder in
                    ListItemView(
                        configuration: .defaultStyle(
                            title: folder.name,
                            leadingView: .empty
                        ),
                        trailingText: "\(folder.documentCount)",
                        trailingView: .chevron
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
}
