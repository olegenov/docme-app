import Foundation
import SwiftUI


extension DocumentListTabbarView {
    struct FilterView: View {
        @Binding var selectedTags: [DocumentCardUI.Color]
        
        let onFilterSelection: (DocumentCardUI.Color) -> Void
        let onCancelFilter: (DocumentCardUI.Color) -> Void
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
                    content: .icon(.init(name: .crossOutline, size: .md)),
                    onTapAction: onClose
                )
            }
        }
    }
}
