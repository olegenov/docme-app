import Foundation
import SwiftUI


extension DocumentListTabbarView {
    struct FilterView: View {
        @Binding var selectedTags: [DocumentCard.Color]
        
        let onFilterSelection: (DocumentCard.Color) -> Void
        let onCancelFilter: (DocumentCard.Color) -> Void
        let onAllFilterSelection: () -> Void
        let onClose: () -> Void
        
        var body: some View {
            HStack(spacing: DS.Spacing.m4) {
                Spacer()
                
                if selectedTags.isNotEmpty {
                    FabView(
                        content: .text(Captions.all),
                        longPaddings: true,
                        onTapAction: onAllFilterSelection
                    )
                }
                
                ForEach(DocumentCard.Color.all, id: \.self) { tag in
                    let selected = selectedTags.contains(tag)
                    FabView(
                        content: .tags(selectedTags: [tag.toTagColor()]),
                        isSelected: selected
                    ) {
                        selected ? onCancelFilter(tag) : onFilterSelection(tag)
                    }
                }
                
                FabView(
                    content: .icon(.init(name: .crossOutline, size: .md)),
                    onTapAction: onClose
                )
            }
        }
    }
}
