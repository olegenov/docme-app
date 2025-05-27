import Foundation
import SwiftUI


struct DocumentCreationTabbarView: View {
    let onCloseTap: () -> Void
    let onCreateTap: () -> Void
    
    var body: some View {
        HStack {
            FabView(
                content: .icon(
                    .init(name: .crossOutline, size: .md)
                ),
                onTapAction: onCloseTap
            )
            
            Spacer()
            
            FabView(
                content: .icon(
                    .init(name: .chevronRightOutline, size: .md)
                ),
                longPaddings: true,
                onTapAction: onCreateTap
            )
        }
    }
}
