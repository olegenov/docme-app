import Foundation
import SwiftUI


struct DocumentListTabbarView: View {
    enum TabbarState: Equatable {
        case none
        
        case defaultView(
            onSearchTap: () -> Void,
            onFilterTap: () -> Void,
            selectedTags: Binding<[DocumentCard.Color]>
        )
        
        case search(
            onSearchClear: () -> Void,
            onSearchClose: () -> Void,
            onSearchChange: (String) -> Void
        )
        
        case filter(
            selectedTags: Binding<[DocumentCard.Color]>,
            onFilterSelection: (DocumentCard.Color) -> Void,
            onCancelFilter: (DocumentCard.Color) -> Void,
            onAllFilterSelection: () -> Void,
            onClose: () -> Void
        )
        
        case folderDetails(
            folder: FolderCard,
            selectedTags: Binding<[DocumentCard.Color]>,
            onParentFolderTap: () -> Void,
            onHomeTap: () -> Void,
            onFilterTap: () -> Void
        )
    }
    
    @Binding var state: TabbarState
    
    @State private var searchFieldWidth: CGFloat = 0
    
    var body: some View {
        VStack {
            switch state {
            case .none: EmptyView()
            case .defaultView(
                let onSearchTap,
                let onFilterTap,
                let selectedTags
            ): DocumentListTabbarView.DefaultView(
                onSearchTap: onSearchTap,
                onFilterTap: onFilterTap,
                selectedTags: selectedTags
            )
            case .filter(
                let selectedTags,
                let onFilterSelection,
                let onCancelFilter,
                let onAllFilterSelection,
                let onClose
            ): DocumentListTabbarView.FilterView(
                selectedTags: selectedTags,
                onFilterSelection: onFilterSelection,
                onCancelFilter: onCancelFilter,
                onAllFilterSelection: onAllFilterSelection,
                onClose: onClose
            )
            case .folderDetails(
                let folder,
                let selectedTags,
                let onParentFolderTap,
                let onHomeTap,
                let onFilterTap
            ): DocumentListTabbarView.FolderDetailsView(
                folder: folder,
                selectedTags: selectedTags,
                onParentFolderTap: onParentFolderTap,
                onHomeTap: onHomeTap,
                onFilterTap: onFilterTap
            )
            case .search(
                let onSearchClear,
                let onSearchClose,
                let onSearchChange
            ): DocumentListTabbarView.SearchView(
                onSearchClear: onSearchClear,
                onSearchClose: onSearchClose,
                onSearchChange: onSearchChange
            )
            }
        }
        .animation(.easeInOut, value: state)
    }
}

extension DocumentListTabbarView.TabbarState {
    static func == (
        lhs: DocumentListTabbarView.TabbarState,
        rhs: DocumentListTabbarView.TabbarState
    ) -> Bool {
        switch (lhs, rhs) {
        case (.defaultView, .defaultView),
             (.search, .search),
             (.filter, .filter),
             (.folderDetails, .folderDetails):
            return true
        default:
            return false
        }
    }
}
