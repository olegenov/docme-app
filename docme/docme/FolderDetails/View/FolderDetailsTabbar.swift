import Foundation
import SwiftUI


struct FolderDetailsTabbarView: View {
    enum TabbarState {
        case defaultState
        case filter
    }
    
    @State var state: TabbarState = .defaultState
    
    let selectedTags: [DocumentCardUI.Color]
    
    let onBackTap: () -> Void
    
    let onFilterSelection: (DocumentCardUI.Color) -> Void
    let onCancelFilter: (DocumentCardUI.Color) -> Void
    let onAllFilterSelection: () -> Void
    
    let isHomeVisible: Bool
    var onHomeTap: (() -> Void)? = nil
    
    @State private var searchText: String = ""
    
    @State private var searchFieldWidth: CGFloat = 0
    
    var body: some View {
        VStack {
            switch state {
            case .defaultState: defaultState
            case .filter: filterState
            }
        }
        .animation(.easeInOut, value: state)
    }
    
    private var defaultState: some View {
        HStack {
            HStack(spacing: DS.Spacing.m4) {
                FabView(
                    content: .icon(
                        .init(name: .chevronLeftOutline, size: .md)
                    ),
                    onTapAction: onBackTap
                )
                
                if isHomeVisible {
                    FabView(
                        content: .icon(
                            .init(name: .homeOutline, size: .md)
                        ),
                        onTapAction: onHomeTap ?? { }
                    )
                }
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

    private var filterState: some View {
        HStack(spacing: DS.Spacing.m4) {
            Spacer()
            
            if selectedTags.isNotEmpty {
                FabView(
                    content: .text(Captions.all),
                    longPaddings: true,
                    onTapAction: onAllFilterSelection
                )
            }
            
            ForEach(DocumentCardUI.Color.all, id: \.self) { tag in
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
