import Foundation
import SwiftUI


struct ItemsList<Content: View>: View {
    @Environment(\.theme) var theme
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: DS.Spacing.m4){
            content()
        }
            .padding(.vertical, DS.Spacing.m4)
            .padding(.horizontal, DS.Spacing.m8)
            .background(theme.colors.overlay)
            .cornerRadius(DS.Spacing.m8)
            .applyShadow(theme.shadows.overlayShadow)
    }
}

#Preview {
    ItemsList {
        ListItem(title: "Text")
        Separator()
        ListItem(title: "Text")
        Separator()
        ListItem(title: "Text", trailingView: .loading)
    }
}
