import Foundation
import SwiftUI


extension DocumentListTabbarView {
    struct DefaultView: View {
        let onSearchTap: () -> Void
        let onFilterTap: () -> Void
        
        @Binding var selectedTags: [DocumentCardUI.Color]
        
        var body: some View {
            HStack {
                FabView(
                    content: .icon(
                        .init(name: .searchOutline, size: .md)
                    ),
                    onTapAction: onSearchTap
                )
                
                Spacer()
                
                FabView(
                    content: .tags(
                        selectedTags: selectedTags.map {
                            $0.toTagColor()
                        }
                    ),
                    onTapAction: onFilterTap
                )
            }
        }
    }
}
