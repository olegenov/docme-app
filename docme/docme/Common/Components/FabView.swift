import Foundation
import SwiftUI


struct FabView: View {
    @Environment(\.theme) var theme
    
    enum Content {
        case icon(_ icon: ImageIcon)
        case iconText(_ icon: ImageIcon, _ text: String)
    }
    
    let content: Content
    
    var body: some View {
        HStack(spacing: DS.Spacing.m4) {
            switch content {
            case .icon(let icon):
                icon
            case .iconText(let icon, let text):
                icon
                Text(text)
            }
        }
        .padding(.vertical, DS.Spacing.m4)
        .padding(.leading, DS.Spacing.m4)
        .padding(.trailing, trailingPadding)
        .background(theme.colors.overlay)
        .cornerRadius(DS.Rounding.m8)
        .applyShadow(theme.shadows.overlayShadow)
    }
    
    private var trailingPadding: CGFloat {
        switch content {
        case .icon:
            return DS.Spacing.m4
        case .iconText:
            return DS.Spacing.m6
        }
    }
}

#Preview {
    VStack {
        FabView(
            content: .icon(.init(
                name: .starOutline,
                size: .md,
                color: .red
            ))
        )
        
        FabView(
            content: .iconText(
                .init(name: .starOutline, size: .md, color: .blue),
                "123"
            )
        )
    }
}
