import Foundation
import SwiftUI


struct Fab: View {
    @Environment(\.theme) var theme
    
    enum Content {
        case icon(_ icon: ImageIcon)
    }
    
    let content: Content
    
    var body: some View {
        HStack {
            switch content {
            case .icon(let icon):
                icon
            }
        }
        .padding(DS.Spacing.m4)
        .background(theme.colors.overlay)
        .cornerRadius(DS.Rounding.m8)
    }
}

#Preview {
    Fab(
        content: .icon(.init(
            name: .starOutline,
            size: .md,
            color: .red
        ))
    )
}
