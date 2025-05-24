import Foundation
import SwiftUI


extension DocumentListTabbarView {
    struct FolderDetailsView: View {
        let folder: FolderUI?
        
        @Binding var selectedTags: [DocumentCardUI.Color]
        
        let onParentFolderTap: () -> Void
        let onHomeTap: () -> Void
        let onFilterTap: () -> Void
        
        var body: some View {
            HStack(spacing: DS.Spacing.m4) {
                if let parentFolder = folder?.parentFolderName {
                    FabView(
                        content: .iconText(
                            .init(name: .chevronLeftOutline, size: .md),
                            parentFolder
                        ),
                        onTapAction: onParentFolderTap
                    )
                    
                    FabView(
                        content: .icon(
                            .init(name: .homeOutline, size: .md)
                        ),
                        onTapAction: onHomeTap
                    )
                } else {
                    FabView(
                        content: .iconText(
                            .init(name: .chevronLeftOutline, size: .md),
                            Captions.mainPage
                        ),
                        onTapAction: onHomeTap
                    )
                }
                
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
