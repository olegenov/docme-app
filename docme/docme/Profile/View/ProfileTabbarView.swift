import Foundation
import SwiftUI


struct ProfileTabbarView: View {
    let onExitAccount: () -> Void
    
    var body: some View {
        HStack() {
            Spacer()
            
            FabView(
                content: .icon(
                    .init(name: .exitOutline, size: .md)
                )
            ) {
                onExitAccount()
            }
        }
    }
}
