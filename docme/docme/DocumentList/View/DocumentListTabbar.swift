import Foundation
import SwiftUI


struct DocumentListTabbarView: View {
    enum TabbarState {
        case defaultState
        case search
        case filter
    }
    
    @State var state: TabbarState = .defaultState
    
    let selectedTags: [DocumentColor]
    
    let onSearchStart: () -> Void
    let onSearchClear: () -> Void
    let onSearchClose: () -> Void
    let onSearchChange: (String) -> Void
    
    let onFilterSelection: (DocumentColor) -> Void
    let onCancelFilter: (DocumentColor) -> Void
    let onAllFilderSelection: () -> Void
    
    @State private var searchText: String = ""
    @State private var isClearingVisible: Bool = false
    
    @State private var searchFieldWidth: CGFloat = 0
    
    var body: some View {
        VStack {
            switch state {
            case .defaultState: defaultState
            case .search: searchState
            case .filter: filterState
            }
        }
        .animation(.easeInOut, value: state)
        .animation(.easeInOut, value: isClearingVisible)
        .onChange(of: searchText) {
            isClearingVisible = searchText.isNotEmpty
            
            if searchText.isEmpty {
                onSearchClear()
                return
            }
            
            onSearchChange(searchText)
        }
    }
    
    private var defaultState: some View {
        HStack {
            FabView(
                content: .icon(
                    .init(name: .searchOutline, size: .md)
                )
            ) {
                state = .search
                onSearchStart()
            }
            
            Spacer()
            
            FabView(
                content: .tags(
                    selectedTags: selectedTags.map {
                        $0.toTagColor()
                    }
                )
            ) {
                state = .filter
            }
        }
    }
    
    private var searchState: some View {
        HStack {
            FabView(
                content: .icon(
                    .init(name: .chevronLeftOutline, size: .md)
                ),
                longPaddings: true
            ) {
                searchText = ""
                state = .defaultState
                onSearchClose()
            }
            
            InputFieldView(
                placeholder: Captions.searchDocs,
                text: $searchText
            )
            
            if isClearingVisible {
                FabView(
                    content: .icon(
                        .init(name: .crossOutline, size: .md)
                    )
                ) {
                    searchText = ""
                    onSearchClear()
                }
            }
        }
    }

    private var filterState: some View {
        HStack(spacing: DS.Spacing.m4) {
            Spacer()
            
            if selectedTags.isNotEmpty {
                FabView(
                    content: .text(Captions.all),
                    longPaddings: true,
                    onTapAction: onAllFilderSelection
                )
            }
            
            ForEach(DocumentColor.all, id: \.self) { tag in
                let selected = selectedTags.contains(tag)
                FabView(
                    content: .tags(selectedTags: [tag.toTagColor()]),
                    isSelected: selected
                ) {
                    selected ? onCancelFilter(tag) : onFilterSelection(tag)
                }
            }
            
            FabView(
                content: .icon(.init(name: .crossOutline, size: .md))
            ) { state = .defaultState }
        }
    }
}
