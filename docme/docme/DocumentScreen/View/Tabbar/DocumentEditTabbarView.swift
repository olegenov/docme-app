import Foundation
import SwiftUI


struct DocumentEditTabbarView: View {
    let onCloseTap: () -> Void
    let onDeleteTap: () -> Void
    let onSaveTap: () -> Void
    
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
                    .init(name: .deleteOutline, size: .md)
                ),
                onTapAction: onDeleteTap
            )
            
            Spacer()
            
            FabView(
                content: .icon(
                    .init(name: .saveOutline, size: .md)
                ),
                onTapAction: onSaveTap
            )
        }
    }
}
