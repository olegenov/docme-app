import Foundation
import SwiftUI


struct DocumentListView<ViewModel: DocumentListViewModel>: View {
    @Environment(\.theme) var theme
    @StateObject var viewModel: ViewModel
    
    let imageManager: ImageManager
    
    @State var isSearching: Bool = false
    
    var body: some View {
        MainContent(
            tabbar: {
                tabbarView
            },
            content: {
                if !isSearching {
                    if viewModel.favorites.isNotEmpty {
                        favoriteSectionView
                    }
                    
                    if viewModel.folders.isNotEmpty {
                        foldersView
                    }
                    
                    documentCollection
                        .padding(.horizontal, DS.Spacing.m8)
                } else {
                    searchResults
                }
            }
        )
        .animation(.easeInOut, value: viewModel.documents)
        .animation(.easeInOut, value: isSearching)
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
            onAllFilderSelection: {
                viewModel.selectAllTags()
            }
        )
    }
    
    private var favoriteSectionView: some View {
        TitledContent(title: Captions.favotites) {
            ScrollView(.horizontal) {
                HStack(spacing: DS.Spacing.m4) {
                    ForEach(viewModel.favorites) { favorite in
                        DocumentCardView(
                            configuration: .sm,
                            leadingView: documentIcon(favorite),
                            title: favorite.title,
                            isFavorite: favorite.isFavorite,
                            imageManager: imageManager
                        )
                    }
                }
            }.scrollClipDisabled()
        }
    }
    
    private var foldersView: some View {
        TitledContent(title: Captions.myDocs) {
            ItemsListView {
                ForEach(Array(viewModel.folders.enumerated()), id: \.element.id) { index, folder in
                    ListItemView(
                        title: folder.name,
                        trailingText: "\(folder.amount)",
                        leadingView: .empty,
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
        HStack(alignment: .top, spacing: DS.Spacing.m4) {
            LazyVStack(alignment: .leading, spacing: DS.Spacing.m4) {
                ForEach(leftColumnItems, id: \.self) { document in
                    documentCollectionItem(document)
                }
            }

            LazyVStack(alignment: .leading, spacing: DS.Spacing.m4) {
                ForEach(rightColumnItems, id: \.self) { document in
                    documentCollectionItem(document)
                }
            }
        }
    }
    
    private var documentList: some View {
        LazyVStack(spacing: DS.Spacing.m8) {
            ForEach(viewModel.documents, id: \.self) { document in
                documentListItem(document)
            }
        }
    }
    
    private var searchResults: some View {
        TitledContent(title: Captions.search) {
            documentList
        }
    }
    
    private var leftColumnItems: [DocumentCardModel] {
        viewModel.documents.enumerated().compactMap { index, element in
            index % 2 == 0 ? element : nil
        }
    }

    private var rightColumnItems: [DocumentCardModel] {
        viewModel.documents.enumerated().compactMap { index, element in
            index % 2 != 0 ? element : nil
        }
    }
    
    private func documentIcon(_ document: DocumentCardModel) -> DocumentCardView.LeadingView {
        guard let iconName = document.icon.toTagIconName() else {
            return .tag(document.documentColor.toTagColor())
        }
        
        return .icon(
            iconName,
            document.documentColor.toIconColor()
        )
    }
    
    @ViewBuilder
    private func documentCollectionItem(_ document: DocumentCardModel) -> some View {
        DocumentCardView(
            configuration: .md(imageUrl: document.imageUrl),
            leadingView: documentIcon(document),
            title: document.title,
            isFavorite: document.isFavorite,
            imageManager: imageManager,
            onFavoriteTap: {
                withAnimation {
                    viewModel.toggleFavorite(for: document)
                }
            }
        )
    }
    
    @ViewBuilder
    private func documentListItem(_ document: DocumentCardModel) -> some View {
        DocumentCardView(
            configuration: .lg(imageUrl: document.imageUrl, date: .now),
            leadingView: documentIcon(document),
            title: document.title,
            isFavorite: document.isFavorite,
            imageManager: imageManager,
            onFavoriteTap: {
                withAnimation {
                    viewModel.toggleFavorite(for: document)
                }
            }
        )
    }
}

#Preview {
    let provider: DocumentListProvider = DocumentListProviderImpl()
    DocumentListCoordinator(provider: provider).start()
}
