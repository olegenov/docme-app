import Foundation
import SwiftUI


struct DocumentViewTabbarView: View {
    let onCloseTap: () -> Void
    let onEditTap: () -> Void
    let onShareTap: () -> Void
    
    var body: some View {
        HStack {
            FabView(
                content: .icon(
                    .init(name: .chevronLeftOutline, size: .md)
                ),
                longPaddings: true,
                onTapAction: onCloseTap
            )
            
            Spacer()
            
            FabView(
                content: .icon(
                    .init(name: .shareOutline, size: .md)
                ),
                onTapAction: onShareTap
            )
            
            Spacer()
            
            FabView(
                content: .icon(
                    .init(name: .editOutline, size: .md)
                ),
                onTapAction: onEditTap
            )
        }
    }
}
